# Soka Rails - Rails Integration for Soka AI Agent Framework

## Project Overview

Soka Rails is a Ruby on Rails integration package for the Soka AI Agent Framework. It provides seamless integration between Soka's ReAct-based AI agents and Rails applications, following Rails conventions and best practices for easy adoption by Rails developers.

## Core Architecture

### Directory Structure
```
soka-rails/
├── app/
│   └── soka/
│       ├── agents/
│       │   └── application_agent.rb       # Rails-specific base agent class
│       └── tools/
│           ├── application_tool.rb        # Rails-specific base tool class
│           └── rails_info_tool.rb         # Built-in Rails info tool
├── lib/
│   ├── soka_rails.rb                     # Main entry point
│   ├── soka/
│   │   └── rails/
│   │       ├── configuration.rb           # Rails-specific configuration
│   │       ├── errors.rb                  # Rails-specific error classes
│   │       ├── railtie.rb                 # Rails integration engine
│   │       ├── rspec.rb                   # RSpec test helpers
│   │       ├── test_helpers.rb            # Testing utilities
│   │       └── version.rb                 # Version information
│   └── generators/
│       └── soka/
│           ├── install/                   # Install generator
│           │   ├── install_generator.rb
│           │   └── templates/
│           │       ├── application_agent.rb
│           │       ├── application_tool.rb
│           │       ├── rails_info_tool.rb
│           │       └── soka.rb           # Initializer template
│           ├── agent/                     # Agent generator
│           │   ├── agent_generator.rb
│           │   └── templates/
│           │       ├── agent.rb.tt
│           │       └── agent_spec.rb.tt
│           └── tool/                      # Tool generator
│               ├── tool_generator.rb
│               └── templates/
│                   ├── tool.rb.tt
│                   └── tool_spec.rb.tt
├── spec/                                  # Test suite
└── soka-rails.gemspec                     # Gem specification
```

## Core Component Descriptions

### 1. Rails Integration (`lib/soka/rails/railtie.rb`)
- Integrates with Rails autoloading system
- Adds `app/soka` to Rails autoload paths
- Configures Rails-specific logging and error handling
- Manages Rails lifecycle hooks

### 2. ApplicationAgent (`app/soka/agents/application_agent.rb`)
- Inherits from `Soka::Agent`
- Provides Rails-specific defaults and configurations
- Integrates with Rails error tracking (Rollbar, Sentry, etc.)
- Supports Rails logging system
- Includes Rails-specific lifecycle hooks

### 3. ApplicationTool (`app/soka/tools/application_tool.rb`)
- Inherits from `Soka::AgentTool`
- Provides Rails-specific helper methods
- Standardized error handling for Rails applications
- Integration with Rails I18n for messages

### 4. RailsInfoTool (`app/soka/tools/rails_info_tool.rb`)
- Built-in tool for accessing Rails application information
- Supports querying:
  - Routes information
  - Rails and Ruby versions
  - Environment details
  - Safe configuration values
- Security-conscious implementation (no sensitive data exposure)

### 5. Configuration System (`lib/soka/rails/configuration.rb`)
- Rails-style configuration using initializers
- Environment-specific configurations
- Supports `Rails.env` based settings
- ENV variable management with `ENV.fetch`

### 6. Generators
- **Install Generator**: Sets up initial structure
- **Agent Generator**: Creates new agent classes with Rails conventions
- **Tool Generator**: Creates new tool classes with parameter definitions
- All generators follow Rails naming conventions and file structure

## Design Decisions

### 1. Following Rails Conventions
- Uses `app/soka` directory for application-specific code
- Follows Rails naming conventions (e.g., `CustomerSupportAgent`)
- Integrates with Rails autoloading via Zeitwerk
- Uses Rails generators for scaffolding

### 2. Rails-Specific Features
- Session-based memory storage
- Integration with Rails authentication systems
- Support for ActionController::Live streaming
- Rails error tracking integration

### 3. Configuration Philosophy
- Environment-based configuration (development, test, production)
- Uses Rails initializer pattern
- Supports Rails credentials for API keys
- Follows 12-factor app principles

### 4. Testing Integration
- Full RSpec integration with custom matchers
- Test helpers for mocking AI responses
- Support for Rails test fixtures
- Integration with Rails testing conventions

## Testing Strategy

### RSpec Integration
- Custom RSpec configuration in `lib/soka/rails/rspec.rb`
- Test helpers for agent and tool testing
- Mock AI response capabilities
- Support for Rails-specific testing patterns

### Test Coverage
- Unit tests for all components
- Integration tests with Rails applications
- Generator tests
- Performance tests for async operations

## Development Guide

### Adding New Agents
1. Use generator: `rails generate soka:agent agent_name`
2. Inherit from `ApplicationAgent`
3. Register required tools
4. Configure AI settings if needed
5. Implement Rails-specific hooks

### Adding New Tools
1. Use generator: `rails generate soka:tool tool_name [param:type ...]`
   - Example: `rails generate soka:tool weather_api location:string units:string`
2. Inherit from `ApplicationTool`
3. Define parameters using DSL (auto-generated if params provided)
4. Implement `call` method
5. Handle Rails-specific concerns (ActiveRecord, etc.)

### Rails Integration Points
- **Controllers**: Direct agent usage in actions
- **Background Jobs**: Agent usage in ActiveJob
- **ActionCable**: Real-time agent interactions
- **ViewComponents**: Agent-powered components

## Rails-Specific Considerations

### Performance
- Non-blocking execution in controllers
- Background job integration for long-running tasks
- Connection pooling for AI providers
- Rails cache integration for responses

### Security
- API keys in Rails credentials
- CSRF protection for agent endpoints
- Authentication integration
- Rate limiting support

### Monitoring
- Rails logger integration
- Performance monitoring (NewRelic, DataDog)
- Error tracking (Rollbar, Sentry)
- Custom Rails instrumentation

## Development Standards

### Code Quality
- **Run RuboCop before committing code**
- **Follow Rails best practices and conventions**
- **Ensure all tests pass before merging**
- **Maintain high test coverage (>90%)**

### Documentation
- **Use YARD format for method documentation**
- **Include usage examples in comments**
- **Document Rails-specific behaviors**
- **Keep README and guides updated**

### Rails Compatibility
- Supports Rails 7.0+
- Ruby 3.4+ required
- Compatible with major Rails gems
- Follows Rails upgrade guides

## Future Enhancements
- [ ] ActiveRecord integration for agent/tool persistence
- [ ] ActionMailer integration for AI-powered emails
- [ ] ViewComponent integration for AI-powered components
- [ ] Hotwire/Turbo integration for real-time updates
- [ ] Rails Admin interface for agent management
- [ ] GraphQL integration for agent APIs

## Dependencies
- Rails >= 7.0
- Soka >= 0.0.1
- Ruby >= 3.4
- Zeitwerk for autoloading

## Common Patterns

### Controller Usage
```ruby
class ConversationsController < ApplicationController
  def create
    agent = CustomerSupportAgent.new
    result = agent.run(params[:message])
    render json: { answer: result.final_answer }
  end
end
```

### Background Job Usage
```ruby
class AgentJob < ApplicationJob
  def perform(message)
    agent = ProcessingAgent.new
    agent.run(message)
  end
end
```

### Testing Pattern
```ruby
RSpec.describe WeatherAgent, type: :agent do
  it "responds to weather queries" do
    mock_ai_response(final_answer: "Sunny, 25°C")
    result = agent.run("What's the weather?")
    expect(result).to be_successful
  end
end
```
