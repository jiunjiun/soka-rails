# frozen_string_literal: true

require 'rails/generators/named_base'

module Soka
  module Generators
    # Generator for creating new Soka agent classes with their associated tests
    class AgentGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :tools, type: :array, default: [], banner: 'tool1 tool2'

      def create_agent_file
        @agent_class_name = agent_class_name
        @tools_list = tools

        template 'agent.rb.tt',
                 File.join('app/soka/agents', class_path, "#{agent_file_name}.rb")
      end

      def create_test_file
        return unless rspec_installed?

        @agent_class_name = agent_class_name

        template 'agent_spec.rb.tt',
                 File.join('spec/soka/agents', class_path, "#{agent_file_name}_spec.rb")
      end

      private

      # Normalize the agent file name to always end with _agent
      def agent_file_name
        base_name = file_name.to_s

        # Remove existing _agent suffix if present to avoid duplication
        base_name = base_name.sub(/_agent\z/, '')

        # Add _agent suffix
        "#{base_name}_agent"
      end

      # Normalize the agent class name to always end with Agent
      def agent_class_name
        base_class = class_name.to_s

        # Remove existing Agent suffix if present to avoid duplication
        base_class = base_class.sub(/Agent\z/, '')

        # Add Agent suffix
        "#{base_class}Agent"
      end

      def rspec_installed?
        File.exist?(::Rails.root.join('spec/spec_helper.rb')) ||
          File.exist?(::Rails.root.join('spec/rails_helper.rb'))
      end
    end
  end
end
