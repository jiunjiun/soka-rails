# frozen_string_literal: true

module Soka
  module Rails
    # Rails integration for Soka, configuring autoloading and initializers
    class Railtie < ::Rails::Railtie
      # Configure autoloading - executed after Rails completes basic setup
      initializer 'soka.setup_autoloading', before: :set_autoload_paths do |app|
        # Add app/soka to autoload paths
        # eager_load: true will automatically include all subdirectories
        app.config.paths.add 'app/soka', eager_load: true
      end
    end
  end
end
