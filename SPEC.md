# Soka Rails - Rails Integration for Soka AI Agent Framework

## Overview

Soka Rails is the Rails integration package for the Soka AI Agent Framework, providing seamless integration with the Rails ecosystem, following Rails conventions, allowing developers to easily use AI Agent in Rails applications.

## Core Features

* **Native Rails Integration**: Following Rails conventions and best practices
* **Autoloading Support**: Automatically loads app/soka directory
* **Generator Support**: Quickly generate Agent and Tool templates
* **Rails Configuration Integration**: Uses Rails configuration system
* **Rails Testing Integration**: Seamless RSpec integration

## Directory Structure

```
rails-app/
├── app/
│   └── soka/
│       ├── agents/              # Agent definitions
│       │   ├── application_agent.rb  # Base Agent class
│       │   ├── weather_agent.rb
│       │   └── support_agent.rb
│       └── tools/               # Tool definitions
│           ├── application_tool.rb   # Base Tool class
│           └── rails_info_tool.rb    # Rails environment info tool
└── config/
    └── initializers/
        └── soka.rb              # Soka global configuration
```

## Installation and Setup

### 1. Install Gem

```ruby
# Gemfile
gem 'soka-rails'
```

### 2. Run Installation Generator

```bash
rails generate soka:install
```

This will generate:
- `config/initializers/soka.rb` - Main configuration file
- `app/soka/agents/application_agent.rb` - Base Agent class
- `app/soka/tools/application_tool.rb` - Base Tool class

## Configuration System

### Main Configuration File (config/initializers/soka.rb)

```ruby
# config/initializers/soka.rb
Soka::Rails.configure do |config|
  # Use environment variables to manage API keys
  config.ai do |ai|
    ai.provider = ENV.fetch('SOKA_PROVIDER', :gemini)
    ai.model = ENV.fetch('SOKA_MODEL', 'gemini-2.5-flash-lite')
    ai.api_key = ENV['SOKA_API_KEY']
  end

  # Performance configuration
  config.performance do |perf|
    perf.max_iterations = Rails.env.production? ? 10 : 5
    perf.timeout = 30.seconds
  end
end
```

## Agent System

### ApplicationAgent Base Class

```ruby
# app/soka/agents/application_agent.rb
class ApplicationAgent < Soka::Agent
  # Default configuration for Rails environment
  if Rails.env.development?
    max_iterations 5
    timeout 15.seconds
  end

  # Auto-register Rails related tools
  tool RailsInfoTool
  tool ApplicationTool
  
  # Rails integration lifecycle hooks
  before_action :log_to_rails
  on_error :notify_error_tracking
  
  private
  
  def log_to_rails(input)
    Rails.logger.info "[Soka] Starting agent execution: #{input}"
  end
  
  def notify_error_tracking(error, context)
    # Integrate Rails error tracking services
    Rails.error.report(error, context: { agent: self.class.name, input: context })
    :continue
  end
end
```

### Custom Agent Example

```ruby
# app/soka/agents/customer_support_agent.rb
class CustomerSupportAgent < ApplicationAgent
  # Register business-related tools
  tool OrderLookupTool
  tool UserInfoTool
  tool RefundTool, if: -> { Current.user&.admin? }
  
  # Integrate Rails authentication
  before_action :authenticate_user!
  
  private
  
  def authenticate_user!
    raise UnauthorizedError unless Current.user.present?
  end
end
```

## Tool System

### Rails-specific Tools

```ruby
# app/soka/tools/rails_info_tool.rb
class RailsInfoTool < ApplicationTool
  desc "Get Rails application information"
  
  params do
    requires :info_type, String, desc: "Type of information",
             validates: { inclusion: { in: %w[routes version environment config] } }
  end
  
  def call(info_type:)
    case info_type
    when 'routes'
      Rails.application.routes.routes.map { |r| format_route(r) }.compact
    when 'version'
      { rails: Rails.version, ruby: RUBY_VERSION, app: Rails.application.class.name }
    when 'environment'
      { env: Rails.env, host: Rails.application.config.hosts.first }
    when 'config'
      safe_config_values
    end
  end
  
  private
  
  def format_route(route)
    return unless route.name
    
    {
      name: route.name,
      verb: route.verb,
      path: route.path.spec.to_s,
      controller: route.defaults[:controller],
      action: route.defaults[:action]
    }
  end
  
  def safe_config_values
    # Only return safe configuration values
    {
      time_zone: Rails.application.config.time_zone,
      locale: I18n.locale
    }
  end
end
```

### Custom Tool Example

```ruby
# app/soka/tools/order_lookup_tool.rb
class OrderLookupTool < ApplicationTool
  desc "Look up order information"
  
  params do
    requires :order_id, String, desc: "Order ID"
    optional :include_items, :boolean, desc: "Include order items", default: false
  end
  
  def call(order_id:, include_items: false)
    # Mock order lookup logic
    order = {
      id: order_id,
      status: "delivered",
      total: "$99.99",
      date: "2025-01-15"
    }
    
    if include_items
      order[:items] = [
        { name: "Product A", quantity: 2, price: "$49.99" }
      ]
    end
    
    order
  rescue => e
    { error: e.message }
  end
end
```

## Generator Support

### Installation Generator

```bash
rails generate soka:install
```

Generated content:
- Configuration file (`config/initializers/soka.rb`)
- Base classes (`ApplicationAgent`, `ApplicationTool`)
- Example Agent and Tool

### Agent Generator

```bash
rails generate soka:agent weather
```

Generates `app/soka/agents/weather_agent.rb`:

```ruby
class WeatherAgent < ApplicationAgent
  # Tool registration
  # tool YourTool
  
  # Configuration
  # max_iterations 10
  # timeout 30.seconds
  
  # Hooks
  # before_action :your_method
  # after_action :your_method
  # on_error :your_method
  
  private
  
  # Implement your private methods
end
```

### Tool Generator

```bash
rails generate soka:tool weather_api
```

Generates `app/soka/tools/weather_api_tool.rb`:

```ruby
class WeatherApiTool < ApplicationTool
  desc "Description of your tool"
  
  params do
    # requires :param_name, String, desc: "Parameter description"
    # optional :param_name, String, desc: "Parameter description"
  end
  
  def call(**params)
    # Implement your tool logic
    "Tool result"
  end
end
```

## Usage Examples

### Basic Usage

```ruby
# Using in Controller
class ConversationsController < ApplicationController
  def create
    agent = CustomerSupportAgent.new
    result = agent.run(params[:message])
    
    render json: {
      answer: result.final_answer,
      confidence: result.confidence_score,
      status: result.status
    }
  end
end
```

### Using Memory

```ruby
class ConversationsController < ApplicationController
  def create
    # Load memory from session
    memory = session[:conversation_memory] || []
    
    agent = CustomerSupportAgent.new(memory: memory)
    result = agent.run(params[:message])
    
    # Update memory
    session[:conversation_memory] = agent.memory.to_a
    
    render json: { answer: result.final_answer }
  end
end
```

### Event Handling

```ruby
class ConversationsController < ApplicationController
  include ActionController::Live
  
  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    agent = CustomerSupportAgent.new
    
    agent.run(params[:message]) do |event|
      response.stream.write("event: #{event.type}\n")
      response.stream.write("data: #{event.content.to_json}\n\n")
    end
  ensure
    response.stream.close
  end
end
```

## Testing Support

### RSpec Integration

```ruby
# spec/rails_helper.rb
require 'soka/rails/rspec'

RSpec.configure do |config|
  config.include Soka::Rails::TestHelpers, type: :agent
  config.include Soka::Rails::TestHelpers, type: :tool
end

# spec/soka/agents/weather_agent_spec.rb  
require 'rails_helper'

RSpec.describe WeatherAgent, type: :agent do
  let(:agent) { described_class.new }
  
  before do
    # Mock AI response
    mock_ai_response(
      final_answer: "Today in Taipei is sunny, temperature 28°C"
    )
  end
  
  it "responds to weather queries" do
    result = agent.run("What's the weather in Taipei today?")
    
    expect(result).to be_successful
    expect(result.final_answer).to include("28°C")
  end
  
  it "handles multiple queries" do
    # First query
    result1 = agent.run("What's the weather today?")
    expect(result1).to be_successful
    
    # Second query
    result2 = agent.run("What's the weather tomorrow?")
    expect(result2).to be_successful
  end
end

# spec/soka/tools/rails_info_tool_spec.rb
RSpec.describe RailsInfoTool, type: :tool do
  let(:tool) { described_class.new }
  
  it "returns Rails version info" do
    result = tool.call(info_type: "version")
    
    expect(result).to include(:rails, :ruby, :app)
    expect(result[:rails]).to eq(Rails.version)
  end
  
  it "returns safe config values only" do
    result = tool.call(info_type: "config")
    
    expect(result).to include(:time_zone, :locale)
    expect(result).not_to include(:secret_key_base)
  end
end
```

## Version Compatibility

- Ruby: >= 3.0
- Rails: >= 7.0  
- Soka: >= 1.0

## Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License