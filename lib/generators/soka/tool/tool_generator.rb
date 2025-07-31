# frozen_string_literal: true

require 'rails/generators/named_base'

module Soka
  module Generators
    # Generator for creating new Soka tool classes with configurable parameters
    class ToolGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      argument :params, type: :array, default: [], banner: 'param1:type param2:type'

      def create_tool_file
        @tool_class_name = tool_class_name
        @params_list = parse_params

        template 'tool.rb.tt',
                 File.join('app/soka/tools', class_path, "#{tool_file_name}.rb")
      end

      def create_test_file
        return unless rspec_installed?

        @tool_class_name = tool_class_name
        @params_list = parse_params

        template 'tool_spec.rb.tt',
                 File.join('spec/soka/tools', class_path, "#{tool_file_name}_spec.rb")
      end

      private

      # Normalize the tool file name to always end with _tool
      def tool_file_name
        base_name = file_name.to_s

        # Remove existing _tool suffix if present to avoid duplication
        base_name = base_name.sub(/_tool\z/, '')

        # Add _tool suffix
        "#{base_name}_tool"
      end

      # Normalize the tool class name to always end with Tool
      def tool_class_name
        base_class = class_name.to_s

        # Remove existing Tool suffix if present to avoid duplication
        base_class = base_class.sub(/Tool\z/, '')

        # Add Tool suffix
        "#{base_class}Tool"
      end

      def parse_params
        params.map do |param|
          name, type = param.split(':')
          { name: name, type: type.capitalize || 'String' }
        end
      end

      def rspec_installed?
        File.exist?(::Rails.root.join('spec/spec_helper.rb')) ||
          File.exist?(::Rails.root.join('spec/rails_helper.rb'))
      end
    end
  end
end
