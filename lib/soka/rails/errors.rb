# frozen_string_literal: true

module Soka
  module Rails
    # Base error class for Soka Rails
    class Error < StandardError; end

    # Configuration related errors
    # Raised when there are configuration-related issues
    class ConfigurationError < Error; end

    # Agent related errors
    # Raised when agent execution encounters problems
    class AgentError < Error; end

    # Tool related errors
    # Raised when tool execution or validation fails
    class ToolError < Error; end

    # Generator related errors
    # Raised when generator operations fail
    class GeneratorError < Error; end

    # Specific error classes
    # Raised when API key is missing for the configured provider
    class MissingApiKeyError < ConfigurationError
      def initialize(provider = nil)
        message = if provider
                    "Missing API key for provider: #{provider}. " \
                      "Please set SOKA_API_KEY or SOKA_#{provider.to_s.upcase}_API_KEY environment variable."
                  else
                    'Missing API key. Please set SOKA_API_KEY environment variable.'
                  end
        super(message)
      end
    end

    # Raised when an unsupported AI provider is specified
    class InvalidProviderError < ConfigurationError
      def initialize(provider)
        super("Invalid AI provider: #{provider}. Supported providers: :gemini, :openai, :anthropic")
      end
    end

    # Raised when agent exceeds maximum allowed iterations
    class MaxIterationsExceededError < AgentError
      def initialize(max_iterations)
        super("Agent exceeded maximum iterations limit of #{max_iterations}")
      end
    end

    # Raised when a requested tool cannot be found
    class ToolNotFoundError < ToolError
      def initialize(tool_name)
        super("Tool not found: #{tool_name}")
      end
    end

    # Raised when tool is called with invalid parameters
    class InvalidToolParametersError < ToolError
      def initialize(tool_name, errors)
        super("Invalid parameters for tool #{tool_name}: #{errors.join(', ')}")
      end
    end
  end
end
