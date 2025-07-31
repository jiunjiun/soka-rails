# frozen_string_literal: true

require_relative 'rails/version'
require_relative 'rails/configuration'
require_relative 'rails/errors'
require_relative 'rails/railtie'
require_relative 'rails/agent_extensions'

module Soka
  # Rails integration for Soka AI Agent Framework
  module Rails
    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end
  end
end
