# Soka Rails

<p align="center">
  <strong>Rails Integration for Soka AI Agent Framework</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#usage">Usage</a> •
  <a href="#generators">Generators</a> •
  <a href="#testing">Testing</a> •
  <a href="#contributing">Contributing</a>
</p>

Soka Rails is a Rails integration package for the Soka AI Agent Framework, providing seamless integration with the Rails ecosystem. It follows Rails conventions and best practices, making it easy for developers to use AI Agents in their Rails applications.

## Features

- 🚂 **Native Rails Integration**: Following Rails conventions and best practices
- 📁 **Auto-loading Support**: Automatically loads the `app/soka` directory
- 🛠️ **Generator Support**: Quickly generate Agent and Tool templates
- ⚙️ **Rails Configuration Integration**: Uses Rails' configuration system
- 🧪 **Rails Testing Integration**: Seamless integration with RSpec
- 🔄 **Rails Lifecycle Hooks**: Integrates with Rails logging and error tracking
- 💾 **Session Memory Support**: Store conversation history in Rails sessions
- 🔐 **Authentication Integration**: Works with Rails authentication systems
- 🗣️ **Custom Instructions**: Customize agent personality and behavior (Soka v0.0.3+)
- 🌐 **Multilingual Thinking**: Support for reasoning in different languages (Soka v0.0.3+)

## Installation

Add the following to your Gemfile:

```ruby
gem 'soka-rails'
```

Then execute:

```bash
bundle install
```

Run the installation generator:

```bash
rails generate soka:install
```

This will generate:
- `config/initializers/soka.rb` - Main configuration file
- `app/soka/agents/application_agent.rb` - Base Agent class
- `app/soka/tools/application_tool.rb` - Base Tool class

## Quick Start

### 1. Configure API Keys

```ruby
# config/initializers/soka.rb
Soka::Rails.configure do |config|
  config.ai do |ai|
    ai.provider = ENV.fetch('SOKA_PROVIDER', :gemini)
    ai.model = ENV.fetch('SOKA_MODEL', 'gemini-2.5-flash-lite')
    ai.api_key = ENV['SOKA_API_KEY']
  end
end
```

### 2. Create an Agent

```bash
rails generate soka:agent customer_support
```

```ruby
# app/soka/agents/customer_support_agent.rb
class CustomerSupportAgent < ApplicationAgent
  tool OrderLookupTool
  tool UserInfoTool
end
```

### 3. Use in Controller

```ruby
class ConversationsController < ApplicationController
  def create
    agent = CustomerSupportAgent.new
    result = agent.run(params[:message])

    render json: {
      answer: result.final_answer,
      status: result.status
    }
  end
end
```

## Usage

### Directory Structure

```
rails-app/
├── app/
│   └── soka/
│       ├── agents/              # Agent definitions
│       │   ├── application_agent.rb
│       │   └── customer_support_agent.rb
│       └── tools/               # Tool definitions
│           ├── application_tool.rb
│           └── order_lookup_tool.rb
└── config/
    └── initializers/
        └── soka.rb              # Global configuration
```

### Creating Agents

```ruby
class WeatherAgent < ApplicationAgent
  # Configure AI settings
  provider :gemini
  model 'gemini-2.5-flash-lite'
  max_iterations 10
  timeout 30.seconds

  # Register tools
  tool WeatherApiTool
  tool LocationTool

  # Rails integration hooks
  before_action :log_request
  on_error :notify_error_service

  private

  def log_request(input)
    Rails.logger.info "[WeatherAgent] Processing: #{input}"
  end

  def notify_error_service(error, context)
    Rails.error.report(error, context: context)
    :continue
  end
end
```

### Creating Tools

```ruby
class OrderLookupTool < ApplicationTool
  desc "Look up order information"

  params do
    requires :order_id, String, desc: "Order ID"
    optional :include_items, :boolean, desc: "Include order items", default: false
  end

  def call(order_id:, include_items: false)
    order = Order.find_by(id: order_id)
    return { error: "Order not found" } unless order

    data = {
      id: order.id,
      status: order.status,
      total: order.total,
      created_at: order.created_at
    }

    data[:items] = order.items if include_items
    data
  end
end
```

### Session Memory

```ruby
class ConversationsController < ApplicationController
  def create
    # Load memory from session
    memory = session[:conversation_memory] || []

    agent = CustomerSupportAgent.new(memory: memory)
    result = agent.run(params[:message])

    # Update session memory
    session[:conversation_memory] = agent.memory.to_a

    render json: { answer: result.final_answer }
  end
end
```

### Event Streaming

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

## Generators

### Install Generator

```bash
rails generate soka:install
```

### Agent Generator

```bash
# Basic usage
rails generate soka:agent weather

# With tools - automatically registers tools in the agent
rails generate soka:agent weather forecast temperature humidity
```

Creates `app/soka/agents/weather_agent.rb` with a template structure.

When tools are specified, the generated agent will include them:

```ruby
class WeatherAgent < ApplicationAgent
  # Tool registration
  tool ForecastTool
  tool TemperatureTool
  tool HumidityTool

  # Custom instructions
  # instructions "You are a weather expert. Always provide temperature in both Celsius and Fahrenheit."

  # Multilingual thinking
  # think_in 'en'  # Supported: 'en', 'zh-TW', 'ja-JP', etc.

  # Configuration
  # max_iterations 10
  # timeout 30
end
```

### Tool Generator

```bash
# Basic usage
rails generate soka:tool weather_api

# With parameters - automatically generates parameter definitions
rails generate soka:tool weather_api location:string units:string timeout:integer
```

Creates `app/soka/tools/weather_api_tool.rb` with parameter definitions.

When parameters are specified, the generated tool will include them:

```ruby
class WeatherApiTool < ApplicationTool
  desc 'Description of your tool'

  params do
    requires :location, String, desc: 'Location'
    requires :units, String, desc: 'Units'
    requires :timeout, Integer, desc: 'Timeout'
  end

  def call(**params)
    # Implement your tool logic here
  end
end
```

## Testing

### RSpec Configuration

```ruby
# spec/rails_helper.rb
require 'soka/rails/rspec'

RSpec.configure do |config|
  config.include Soka::Rails::TestHelpers, type: :agent
  config.include Soka::Rails::TestHelpers, type: :tool
end
```

### Testing Agents

```ruby
RSpec.describe WeatherAgent, type: :agent do
  let(:agent) { described_class.new }

  before do
    mock_ai_response(
      final_answer: "Today in Tokyo it's sunny with 28°C"
    )
  end

  it "responds to weather queries" do
    result = agent.run("What's the weather in Tokyo?")

    expect(result).to be_successful
    expect(result.final_answer).to include("28°C")
  end
end
```

### Testing Tools

```ruby
RSpec.describe OrderLookupTool, type: :tool do
  let(:tool) { described_class.new }
  let(:order) { create(:order, id: "123", status: "delivered") }

  it "finds existing orders" do
    result = tool.call(order_id: order.id)

    expect(result[:status]).to eq("delivered")
    expect(result[:id]).to eq("123")
  end

  it "handles missing orders" do
    result = tool.call(order_id: "nonexistent")

    expect(result[:error]).to include("not found")
  end
end
```

## Rails-Specific Tools

### RailsInfoTool

A built-in tool for accessing Rails application information:

```ruby
class RailsInfoTool < ApplicationTool
  desc "Get Rails application information"

  params do
    requires :info_type, String, desc: "Type of information",
             validates: { inclusion: { in: %w[routes version environment config] } }
  end

  def call(info_type:)
    case info_type
    when 'routes'
      # Returns application routes
    when 'version'
      # Returns Rails and Ruby versions
    when 'environment'
      # Returns environment information
    when 'config'
      # Returns safe configuration values
    end
  end
end
```

## Configuration

### Environment-based Configuration

```ruby
Soka::Rails.configure do |config|
  config.ai do |ai|
    ai.provider = ENV.fetch('SOKA_PROVIDER', :gemini)
    ai.model = ENV.fetch('SOKA_MODEL', 'gemini-2.5-flash-lite')
    ai.api_key = ENV['SOKA_API_KEY']
  end

  config.performance do |perf|
    perf.max_iterations = Rails.env.production? ? 10 : 5
    perf.timeout = 30.seconds
  end
end
```

## Compatibility

- Ruby: >= 3.4
- Rails: >= 7.0
- Soka: >= 1.0

## Contributing

We welcome all forms of contributions!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- Add appropriate tests
- Update relevant documentation
- Follow Rails coding conventions
- Pass Rubocop checks

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ for the Rails Community<br>
  Built on top of <a href="https://github.com/jiunjiun/soka">Soka AI Agent Framework</a><br>
  Created by <a href="https://claude.ai/code">Claude Code</a>
</p>
