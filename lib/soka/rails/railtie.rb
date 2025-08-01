# frozen_string_literal: true

require 'soka'

module Soka
  module Rails
    # Rails integration for Soka, configuring autoloading and initializers
    #
    # This Railtie ensures that Soka agents and tools can be autoloaded
    # properly by Rails' Zeitwerk autoloader. It sets up app/soka as a
    # root directory and collapses subdirectories to avoid namespace requirements.
    #
    # @example Directory structure
    #   app/soka/
    #   ├── agents/
    #   │   ├── application_agent.rb  # Defines ApplicationAgent (not Agents::ApplicationAgent)
    #   │   └── search_agent.rb       # Defines SearchAgent (not Agents::SearchAgent)
    #   └── tools/
    #       ├── application_tool.rb   # Defines ApplicationTool (not Tools::ApplicationTool)
    #       └── search_tool.rb        # Defines SearchTool (not Tools::SearchTool)
    class Railtie < ::Rails::Railtie
      # Configuration for collapsed directories
      # Users can modify this in an initializer if needed
      config.soka_collapsed_dirs = %w[agents tools]

      # Set up Zeitwerk autoloading for Soka directories
      #
      # This initializer runs after Rails sets up its autoloaders but before
      # eager loading begins. It configures app/soka as a root directory
      # and collapses specified subdirectories.
      initializer 'soka.setup_autoloading',
                  after: :setup_once_autoloader,
                  before: :eager_load! do |app|
        setup_soka_autoloading(app)
      end

      private

      def setup_soka_autoloading(app)
        soka_path = app.root.join('app/soka')
        return unless soka_path.exist?

        configure_autoloader(soka_path)
      rescue StandardError => e
        ::Rails.logger&.error "[Soka] Failed to configure autoloading: #{e.message}"
        raise
      end

      def configure_autoloader(soka_path)
        # Add app/soka as a root directory without namespace
        # This allows classes in app/soka to be loaded at the top level
        ::Rails.autoloaders.main.push_dir(soka_path.to_s)

        # Collapse configured directories
        # This removes the directory name from the expected constant path
        # e.g., app/soka/agents/foo.rb defines Foo instead of Agents::Foo
        config.soka_collapsed_dirs.each do |dir|
          dir_path = soka_path.join(dir)
          ::Rails.autoloaders.main.collapse(dir_path.to_s) if dir_path.exist?
        end

        ::Rails.logger&.debug "[Soka] Configured autoloading for #{soka_path}"
      end
    end
  end
end
