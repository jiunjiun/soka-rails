# frozen_string_literal: true

require 'soka/rails/test_helpers'

if defined?(RSpec)
  RSpec.configure do |config|
    config.include Soka::Rails::TestHelpers, type: :agent
    config.include Soka::Rails::TestHelpers, type: :tool

    config.before(:each, type: :agent) do
      # Reset Soka configuration
      Soka.configuration = Soka::Configuration.new if defined?(Soka) && Soka.respond_to?(:configuration=)
    end

    config.before(:each, type: :tool) do
      # Ensure Rails environment is available
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test')) if defined?(Rails)
    end

    # Automatically tag tests under spec/soka directory
    config.define_derived_metadata(file_path: %r{/spec/soka/agents/}) do |metadata|
      metadata[:type] = :agent
    end

    config.define_derived_metadata(file_path: %r{/spec/soka/tools/}) do |metadata|
      metadata[:type] = :tool
    end
  end
end
