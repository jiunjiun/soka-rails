# frozen_string_literal: true

module Soka
  module Rails
    # Extensions for Soka::Agent to integrate with Rails configuration
    module AgentExtensions
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class methods for agent configuration
      module ClassMethods
        def inherited(subclass)
          super
          apply_rails_configuration(subclass)
        end

        private

        def apply_rails_configuration(subclass)
          return unless defined?(Soka::Rails.configuration)

          rails_config = Soka::Rails.configuration
          apply_configuration_values(subclass, rails_config)
        end

        def apply_configuration_values(subclass, config)
          return unless config

          subclass.provider config.ai_provider if config.ai_provider
          subclass.model config.ai_model if config.ai_model
          subclass.api_key config.ai_api_key if config.ai_api_key
          subclass.max_iterations config.max_iterations if config.max_iterations
        end
      end
    end
  end
end

# Apply extensions to Soka::Agent
Soka::Agent.include(Soka::Rails::AgentExtensions) if defined?(Soka::Agent)
