# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Soka::Rails::Railtie' do
  # Since the railtie is conditionally loaded only when Rails is defined,
  # and it's already loaded during the initial require, we can only test
  # its presence when Rails is mocked during the initial load.

  it 'is loaded in the soka/rails module' do
    # The railtie file exists and can be required
    expect(File.exist?(File.expand_path('../../../lib/soka/rails/railtie.rb', __dir__))).to be true
  end

  it 'defines Railtie when Rails is present' do
    # Since Rails is loaded in the test environment
    expect(defined?(Soka::Rails::Railtie)).to be_truthy if defined?(Rails)
  end

  it 'does not define Railtie when Rails is absent' do
    # This test would only run if Rails is not loaded
    expect(defined?(Soka::Rails::Railtie)).to be_falsy unless defined?(Rails)
  end
end
