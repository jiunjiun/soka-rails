# frozen_string_literal: true

require 'rails/generators/base'

module Soka
  module Generators
    # Generator for installing Soka Rails configuration
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

      def add_soka_directory
        empty_directory 'app/soka'
        empty_directory 'app/soka/agents'
        empty_directory 'app/soka/tools'
      end

      def display_post_install_message
        say "\nSoka Rails has been successfully installed!", :green
        say "\nNext steps:"
        say '  1. Set your AI provider API key: GEMINI_API_KEY, OPENAI_API_KEY, ANTHROPIC_API_KEY'
        say '  2. Create your first agent: rails generate soka:agent MyAgent'
        say '  3. Create your first tool: rails generate soka:tool MyTool'
        say "\nFor more information, visit: https://github.com/jiunjiun/soka-rails"
      end
    end
  end
end
