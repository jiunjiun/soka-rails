# Soka Rails Design Document

## 1. System Architecture Design

### 1.1 Overall Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       Rails Application                      │
├─────────────────────────────────────────────────────────────┤
│                      Soka Rails Layer                        │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Railtie   │  │  Generators  │  │   Test Helpers   │  │
│  └─────────────┘  └──────────────┘  └──────────────────┘  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │Configuration│  │ Agent Bridge │  │   Tool Bridge    │  │
│  └─────────────┘  └──────────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                      Soka Core Framework                     │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │    Agent    │  │     Tool     │  │    ReAct Engine  │  │
│  └─────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Module Design

#### 1.2.1 Core Module Structure
```ruby
module Soka
  module Rails
    # Version definition
    VERSION = "0.0.1.beta1"

    # Main components
    class Railtie < ::Rails::Railtie; end
    class Configuration; end
    class Engine < ::Rails::Engine; end

    # Bridge layer
    module AgentBridge; end
    module ToolBridge; end

    # Test support
    module TestHelpers; end

    # Generator namespace
    module Generators; end
  end
end
```

## 2. Core Component Design

### 2.1 Railtie Design (FR-001, FR-002)

```ruby
# lib/soka/rails/railtie.rb
module Soka
  module Rails
    class Railtie < ::Rails::Railtie
      # Autoload path configuration
      initializer "soka.autoload_paths" do |app|
        app.config.autoload_paths << app.root.join("app/soka")
        app.config.eager_load_paths << app.root.join("app/soka")
      end

      # Load configuration
      initializer "soka.load_configuration" do
        config_file = ::Rails.root.join("config/initializers/soka.rb")
        require config_file if config_file.exist?
      end

      # Setup Zeitwerk
      initializer "soka.setup_zeitwerk" do
        ::Rails.autoloaders.main.push_dir(
          ::Rails.root.join("app/soka"),
          namespace: Object
        )
      end

      # Integrate Rails logger
      initializer "soka.setup_logger" do
        Soka.configure do |config|
          config.logger = ::Rails.logger
        end
      end

      # Development environment hot reload
      if ::Rails.env.development?
        config.to_prepare do
          # Reload Soka related classes
          Dir[::Rails.root.join("app/soka/**/*.rb")].each { |f| load f }
        end
      end
    end
  end
end
```

### 2.2 Configuration Design (FR-004, FR-010)

```ruby
# lib/soka/rails/configuration.rb
module Soka
  module Rails
    class Configuration
      attr_accessor :ai_provider, :ai_model, :ai_api_key
      attr_accessor :max_iterations, :timeout

      def initialize
        # Use ENV.fetch to set default values
        @ai_provider = ENV.fetch('SOKA_PROVIDER', :gemini).to_sym
        @ai_model = ENV.fetch('SOKA_MODEL', 'gemini-2.0-flash-exp')
        @ai_api_key = ENV.fetch('SOKA_API_KEY', nil)

        # Performance settings
        @max_iterations = ::Rails.env.production? ? 10 : 5
        @timeout = 30.seconds
      end

      # DSL configuration methods
      def ai
        yield(AIConfig.new(self)) if block_given?
      end

      def performance
        yield(PerformanceConfig.new(self)) if block_given?
      end

      # Internal configuration classes
      class AIConfig
        def initialize(config)
          @config = config
        end

        def provider=(value)
          @config.ai_provider = value
        end

        def model=(value)
          @config.ai_model = value
        end

        def api_key=(value)
          @config.ai_api_key = value
        end
      end

      class PerformanceConfig
        def initialize(config)
          @config = config
        end

        def max_iterations=(value)
          @config.max_iterations = value
        end

        def timeout=(value)
          @config.timeout = value
        end
      end
    end

    # Global configuration methods
    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end
  end
end
```

### 2.3 ApplicationAgent Design (FR-006, FR-007)

```ruby
# app/soka/agents/application_agent.rb
class ApplicationAgent < Soka::Agent
  # Rails environment default configuration
  if defined?(::Rails)
    max_iterations ::Rails.env.production? ? 10 : 5
    timeout 30.seconds
  end

  # Default tools
  tool RailsInfoTool if defined?(RailsInfoTool)

  # Rails integration hooks
  before_action :log_agent_start
  after_action :log_agent_complete
  on_error :handle_agent_error

  private

  # Log Agent start execution
  def log_agent_start(input)
    ::Rails.logger.info "[Soka] #{self.class.name} started: #{input.truncate(100)}"
    tag_request
  end

  # Log Agent completion
  def log_agent_complete(result)
    ::Rails.logger.info "[Soka] #{self.class.name} completed: #{result.status}"
    cleanup_request_tags
  end

  # Error handling and tracking
  def handle_agent_error(error, context)
    ::Rails.logger.error "[Soka] #{self.class.name} error: #{error.message}"
    ::Rails.logger.error error.backtrace.join("\n")

    # Integrate Rails error tracking
    if defined?(::Rails.error)
      ::Rails.error.report(error,
        context: {
          agent: self.class.name,
          input: context[:input],
          iteration: context[:iteration]
        }
      )
    end

    :continue # Allow continuing execution
  end

  # Tag request for tracking
  def tag_request
    return unless defined?(::Rails.application.config.log_tags)

    request_id = SecureRandom.uuid
    Thread.current[:soka_request_id] = request_id
  end

  def cleanup_request_tags
    Thread.current[:soka_request_id] = nil
  end
end
```

### 2.4 ApplicationTool Design (FR-008)

```ruby
# app/soka/tools/application_tool.rb
class ApplicationTool < Soka::AgentTool
  # Rails specific helper methods

  protected

  # Safe parameter filtering
  private
  def safe_params(params)
    ActionController::Parameters.new(params).permit!
  end
end
```

### 2.5 RailsInfoTool Design (FR-009)

```ruby
# app/soka/tools/rails_info_tool.rb
class RailsInfoTool < ApplicationTool
  desc "Get Rails application information"

  params do
    requires :info_type, String,
             desc: "Type of information to retrieve",
             validates: {
               inclusion: {
                 in: %w[routes version environment config]
               }
             }
  end

  def call(info_type:)
    case info_type
    when 'routes'
      fetch_routes_info
    when 'version'
      fetch_version_info
    when 'environment'
      fetch_environment_info
    when 'config'
      fetch_safe_config_info
    end
  end

  private

  def fetch_routes_info
    routes = ::Rails.application.routes.routes.map do |route|
      next unless route.name.present?

      {
        name: route.name,
        verb: route.verb,
        path: route.path.spec.to_s,
        controller: route.defaults[:controller],
        action: route.defaults[:action]
      }
    end.compact

    { routes: routes }
  end

  def fetch_version_info
    {
      rails_version: ::Rails.version,
      ruby_version: RUBY_VERSION,
      app_name: ::Rails.application.class.module_parent_name,
      environment: ::Rails.env
    }
  end

  def fetch_environment_info
    {
      rails_env: ::Rails.env,
      time_zone: Time.zone.name,
      host: ::Rails.application.config.hosts.first.to_s,
      database: ActiveRecord::Base.connection.adapter_name
    }
  end

  def fetch_safe_config_info
    # Only return safe configuration values
    safe_configs = {
      time_zone: ::Rails.application.config.time_zone,
      locale: I18n.locale.to_s,
      default_locale: I18n.default_locale.to_s,
      available_locales: I18n.available_locales.map(&:to_s),
      eager_load: ::Rails.application.config.eager_load,
      consider_all_requests_local: ::Rails.application.config.consider_all_requests_local,
      force_ssl: ::Rails.application.config.force_ssl,
      public_file_server_enabled: ::Rails.application.config.public_file_server.enabled
    }

    safe_configs
  end
end
```

## 3. Generator Design (FR-003)

### 3.1 Install Generator

```ruby
# lib/generators/soka/install/install_generator.rb
module Soka
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template 'soka.rb', 'config/initializers/soka.rb'
      end

      def create_application_agent
        template 'application_agent.rb', 'app/soka/agents/application_agent.rb'
      end

      def create_application_tool
        template 'application_tool.rb', 'app/soka/tools/application_tool.rb'
      end

      def create_rails_info_tool
        template 'rails_info_tool.rb', 'app/soka/tools/rails_info_tool.rb'
      end

      def add_soka_directory
        empty_directory 'app/soka'
        empty_directory 'app/soka/agents'
        empty_directory 'app/soka/tools'
      end

      def display_post_install_message
        say "\nSoka Rails has been successfully installed!", :green
        say "\nNext steps:"
        say "  1. Set your AI provider API key: SOKA_API_KEY=your_key"
        say "  2. Create your first agent: rails generate soka:agent MyAgent"
        say "  3. Create your first tool: rails generate soka:tool MyTool"
      end
    end
  end
end
```

### 3.2 Agent Generator

```ruby
# lib/generators/soka/agent/agent_generator.rb
module Soka
  module Generators
    class AgentGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :tools, type: :array, default: [], banner: "tool1 tool2"

      def create_agent_file
        @agent_class_name = class_name
        @tools_list = tools

        template 'agent.rb.tt',
                 File.join('app/soka/agents', class_path, "#{file_name}_agent.rb")
      end

      def create_test_file
        @agent_class_name = class_name

        template 'agent_spec.rb.tt',
                 File.join('spec/soka/agents', class_path, "#{file_name}_agent_spec.rb")
      end
    end
  end
end
```

### 3.3 Tool Generator

```ruby
# lib/generators/soka/tool/tool_generator.rb
module Soka
  module Generators
    class ToolGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :params, type: :array, default: [], banner: 'param1:type param2:type'

      def create_tool_file
        @tool_class_name = class_name
        @params_list = parse_params

        template 'tool.rb.tt',
                 File.join('app/soka/tools', class_path, "#{file_name}_tool.rb")
      end

      def create_test_file
        @tool_class_name = class_name

        template 'tool_spec.rb.tt',
                 File.join('spec/soka/tools', class_path, "#{file_name}_tool_spec.rb")
      end

      private

      def parse_params
        params.map do |param|
          name, type = param.split(':')
          { name: name, type: type || 'String' }
        end
      end
    end
  end
end
```

## 4. Test Support Design (FR-005)

### 4.1 RSpec Test Helpers

```ruby
# lib/soka/rails/test_helpers.rb
module Soka
  module Rails
    module TestHelpers
      extend ActiveSupport::Concern

      included do
        let(:mock_llm) { instance_double(Soka::LLM) }
      end

      # Mock AI response
      def mock_ai_response(response_attrs = {})
        default_response = {
          final_answer: "Mocked answer",
          confidence_score: 0.95,
          status: :completed,
          iterations: 1,
          thought_process: []
        }

        response = default_response.merge(response_attrs)

        allow(Soka::LLM).to receive(:new).and_return(mock_llm)
        allow(mock_llm).to receive(:chat).and_return(
          OpenStruct.new(content: build_react_response(response))
        )
      end

      # Mock tool execution
      def mock_tool_execution(tool_class, result)
        allow_any_instance_of(tool_class).to receive(:call).and_return(result)
      end

      # Build ReAct format response
      def build_react_response(attrs)
        thoughts = attrs[:thought_process].presence ||
                  ["Analyzing the request"]

        response = thoughts.map { |t| "<Thought>#{t}</Thought>" }.join("\n")
        response += "\n<Final_Answer>#{attrs[:final_answer]}</Final_Answer>"
        response
      end

      # Agent test helper methods
      def run_agent(agent, input, &block)
        result = nil

        if block_given?
          result = agent.run(input, &block)
        else
          result = agent.run(input)
        end

        expect(result).to be_a(Struct)
        result
      end

      # Event collector
      def collect_agent_events(agent, input)
        events = []

        agent.run(input) do |event|
          events << event
        end

        events
      end

      # Test configuration
      def with_test_configuration
        original_config = Soka::Rails.configuration.dup

        Soka::Rails.configure do |config|
          config.ai_provider = :mock
          config.max_iterations = 3
          config.timeout = 5.seconds
          yield config if block_given?
        end

        yield
      ensure
        Soka::Rails.configuration = original_config
      end
    end
  end
end
```

### 4.2 RSpec Configuration

```ruby
# lib/soka/rails/rspec.rb
require 'soka/rails/test_helpers'

RSpec.configure do |config|
  config.include Soka::Rails::TestHelpers, type: :agent
  config.include Soka::Rails::TestHelpers, type: :tool

  config.before(:each, type: :agent) do
    # Reset Soka configuration
    Soka.configuration = Soka::Configuration.new
  end

  config.before(:each, type: :tool) do
    # Ensure tools are available
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
  end
end
```

## 5. Integration Points Design

### 5.1 Controller Integration

```ruby
# Example: Using in Controller
class ConversationsController < ApplicationController
  def create
    agent = CustomerSupportAgent.new(
      memory: session_memory,
      context: current_user_context
    )

    result = agent.run(conversation_params[:message])

    session[:conversation_memory] = agent.memory.to_a

    respond_to do |format|
      format.json { render json: build_response(result) }
      format.html { redirect_to conversation_path, notice: result.final_answer }
    end
  rescue Soka::Error => e
    handle_soka_error(e)
  end

  private

  def session_memory
    Soka::Memory.new(session[:conversation_memory] || [])
  end

  def current_user_context
    {
      user_id: current_user.id,
      user_name: current_user.name,
      user_role: current_user.role
    }
  end

  def build_response(result)
    {
      answer: result.final_answer,
      confidence: result.confidence_score,
      status: result.status,
      metadata: {
        iterations: result.iterations,
        timestamp: Time.current
      }
    }
  end

  def handle_soka_error(error)
    Rails.logger.error "[Soka Error] #{error.message}"
    render json: { error: "AI processing error occurred" }, status: :internal_server_error
  end
end
```

### 5.2 ActiveJob Integration

```ruby
# Example: Background job integration
class ProcessConversationJob < ApplicationJob
  queue_as :default

  def perform(user_id, message)
    user = User.find(user_id)
    agent = CustomerSupportAgent.new(
      memory: user.conversation_memory,
      context: { user_id: user.id }
    )

    result = agent.run(message)

    # Save result
    user.conversations.create!(
      message: message,
      response: result.final_answer,
      confidence: result.confidence_score,
      metadata: {
        iterations: result.iterations,
        thought_process: result.thought_process
      }
    )

    # Send notification
    UserMailer.conversation_processed(user, result).deliver_later
  end
end
```

### 5.3 ActionCable Integration

```ruby
# Example: Real-time communication integration
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "conversation_#{params[:conversation_id]}"
  end

  def receive(data)
    agent = CustomerSupportAgent.new

    agent.run(data['message']) do |event|
      ActionCable.server.broadcast(
        "conversation_#{params[:conversation_id]}",
        {
          type: event.type,
          content: event.content,
          timestamp: Time.current
        }
      )
    end
  end
end
```

## 6. Performance Optimization Design

### 6.1 Connection Pool Design

```ruby
module Soka
  module Rails
    class ConnectionPool
      include Singleton

      def initialize
        @pools = {}
        @mutex = Mutex.new
      end

      def with_connection(provider, &block)
        pool = get_pool(provider)
        pool.with(&block)
      end

      private

      def get_pool(provider)
        @mutex.synchronize do
          @pools[provider] ||= ConnectionPool.new(
            size: pool_size,
            timeout: pool_timeout
          ) do
            create_connection(provider)
          end
        end
      end

      def pool_size
        ::Rails.env.production? ? 10 : 2
      end

      def pool_timeout
        5.seconds
      end

      def create_connection(provider)
        Soka::LLM.new(provider: provider)
      end
    end
  end
end
```

## 7. Error Handling Design

### 7.1 Error Class Hierarchy

```ruby
module Soka
  module Rails
    class Error < StandardError; end

    class ConfigurationError < Error; end
    class AgentError < Error; end
    class ToolError < Error; end
    class GeneratorError < Error; end

    # Specific errors
    class MissingApiKeyError < ConfigurationError
      def initialize(provider)
        super("Missing API key for provider: #{provider}")
      end
    end

    class InvalidProviderError < ConfigurationError
      def initialize(provider)
        super("Invalid AI provider: #{provider}")
      end
    end

    class AgentTimeoutError < AgentError
      def initialize(timeout)
        super("Agent execution timeout after #{timeout} seconds")
      end
    end
  end
end
```

## 8. Security Design (NFR-003)

### 8.1 API Key Management

```ruby
module Soka
  module Rails
    module Security
      class ApiKeyManager
        def self.fetch_api_key(provider)
          key = ENV.fetch("SOKA_#{provider.upcase}_API_KEY") do
            ENV.fetch('SOKA_API_KEY', nil)
          end

          raise MissingApiKeyError.new(provider) if key.blank?

          key
        end

        def self.validate_api_key(key)
          return false if key.blank?
          return false if key.length < 20
          return false if key.include?(' ')

          true
        end
      end
    end
  end
end
```

### 8.2 Parameter Filtering

```ruby
module Soka
  module Rails
    module Security
      module ParameterFiltering
        extend ActiveSupport::Concern

        FILTERED_PARAMS = %w[
          api_key
          password
          secret
          token
          auth
        ].freeze

        def filter_sensitive_params(params)
          filtered = params.deep_dup

          FILTERED_PARAMS.each do |param|
            filtered.deep_transform_keys! do |key|
              if key.to_s.downcase.include?(param)
                filtered[key] = '[FILTERED]'
              end
            end
          end

          filtered
        end
      end
    end
  end
end
```

## 9. Deployment Considerations

### 9.1 Gem Structure

```
soka-rails/
├── lib/
│   ├── soka-rails.rb
│   ├── soka/
│   │   └── rails/
│   │       ├── version.rb
│   │       ├── railtie.rb
│   │       ├── configuration.rb
│   │       ├── test_helpers.rb
│   │       └── rspec.rb
│   └── generators/
│       └── soka/
│           ├── install/
│           ├── agent/
│           └── tool/
├── app/
│   └── soka/
│       ├── agents/
│       │   └── application_agent.rb
│       └── tools/
│           ├── application_tool.rb
│           └── rails_info_tool.rb
├── spec/
├── Gemfile
├── soka-rails.gemspec
├── README.md
└── LICENSE
```

### 9.2 Gemspec Configuration

```ruby
# frozen_string_literal: true

require_relative 'lib/soka/rails/version'

Gem::Specification.new do |spec|
  spec.name = 'soka-rails'
  spec.version = Soka::Rails::VERSION
  spec.authors = ['jiunjiun']
  spec.email = ['imjiunjiun@gmail.com']

  spec.summary = 'Rails integration for Soka AI Agent Framework'
  spec.description = 'Soka Rails provides seamless integration between the Soka AI Agent Framework ' \
                     'and Ruby on Rails applications, following Rails conventions for easy adoption.'
  spec.homepage = 'https://github.com/jiunjiun/soka-rails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jiunjiun/soka-rails'
  spec.metadata['changelog_uri'] = 'https://github.com/jiunjiun/soka-rails/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github/ appveyor Gemfile])
    end
  end

  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'rails', '>= 7.0', '< 9.0'
  spec.add_dependency 'soka', '~> 0.0.1'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # Development dependencies
  spec.add_development_dependency 'rspec-rails', '~> 6.1'
  spec.add_development_dependency 'rubocop', '~> 1.60'
  spec.add_development_dependency 'rubocop-rails', '~> 2.23'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.25'
  spec.add_development_dependency 'pry-rails', '~> 0.3'
  spec.add_development_dependency 'yard', '~> 0.9'
end
```

## 10. Implementation Priority

### Phase 1: Core Foundation (Week 1-2)
1. Railtie implementation
2. Configuration system
3. Base Agent/Tool classes

### Phase 2: Generator (Week 3-4)
1. Install Generator
2. Agent Generator
3. Tool Generator

### Phase 3: Test Support (Week 5-6)
1. RSpec Test Helpers
2. Mock system
3. Test examples

### Phase 4: Advanced Features (Week 7-8)
1. Connection pool optimization
2. Performance optimization
3. Error handling improvements

### Phase 5: Documentation & Release (Week 9-10)
1. API documentation
2. Usage guide
3. Gem release preparation