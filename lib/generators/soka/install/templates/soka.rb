# frozen_string_literal: true

# Soka Rails configuration
Soka::Rails.configure do |config|
  # AI Provider Configuration
  config.ai do |ai|
    # Setup Gemini AI Studio
    ai.provider = :gemini
    ai.model = 'gemini-2.5-flash-lite'
    ai.api_key = ENV.fetch('GEMINI_API_KEY', nil)

    # Setup OpenAI
    # ai.provider = :openai
    # ai.model = 'gpt-4.1-mini'
    # ai.api_key = ENV.fetch('OPENAI_API_KEY', nil)

    # Setup Anthropic
    # ai.provider = :anthropic
    # ai.model = 'claude-sonnet-4-0'
    # ai.api_key = ENV.fetch('ANTHROPIC_API_KEY', nil)
  end

  # Performance Configuration
  config.performance do |perf|
    # Maximum iterations for ReAct loop
    perf.max_iterations = Rails.env.production? ? 10 : 5

    # Timeout for agent execution (in seconds)
    perf.timeout = 30
  end
end
