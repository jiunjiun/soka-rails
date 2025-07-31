# frozen_string_literal: true

require 'bundler/setup'
require 'soka_rails'
require 'fileutils'

# Load support files
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

# Rails generator testing support
module GeneratorTestHelpers
  def self.included(base)
    base.class_eval do
      def self.destination(path)
        define_method(:destination_root) { path }
      end

      def prepare_destination
        FileUtils.rm_rf(destination_root)
        FileUtils.mkdir_p(destination_root)
      end
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include generator helpers for generator specs
  config.include GeneratorTestHelpers, type: :generator
end
