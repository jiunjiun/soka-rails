# frozen_string_literal: true

module Soka
  module Rails
    # Main configuration class for Soka Rails settings
    class Configuration
      attr_accessor :ai_provider, :ai_model, :ai_api_key, :max_iterations, :timeout

      def initialize
        # Use ENV.fetch to set default values
        @ai_provider = ENV.fetch('SOKA_PROVIDER', :gemini).to_sym
        @ai_model = ENV.fetch('SOKA_MODEL', 'gemini-2.0-flash-exp')
        @ai_api_key = ENV.fetch('SOKA_API_KEY', nil)

        # Performance settings
        @max_iterations = defined?(::Rails) && ::Rails.env.production? ? 10 : 5
        @timeout = 30
      end

      # DSL configuration methods
      def ai
        yield(AIConfig.new(self)) if block_given?
      end

      def performance
        yield(PerformanceConfig.new(self)) if block_given?
      end

      # Internal configuration classes
      # DSL class for AI-specific configuration settings
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

      # DSL class for performance-related configuration settings
      class PerformanceConfig
        def initialize(config)
          @config = config
        end

        def max_iterations=(value)
          @config.max_iterations = value
        end

        def timeout=(value)
          @config.timeout = value.is_a?(Numeric) ? value : value.to_i
        end
      end
    end
  end
end
