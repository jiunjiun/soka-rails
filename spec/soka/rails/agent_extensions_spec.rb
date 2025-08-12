# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Soka::Rails::AgentExtensions do
  let(:mock_agent_class) do
    Class.new do
      class << self
        attr_accessor :_provider, :_model, :_api_key, :_max_iterations

        %i[provider model api_key max_iterations].each do |method|
          define_method(method) { |value| instance_variable_set("@_#{method}", value) }
        end
      end
    end
  end

  describe '#apply_rails_configuration with full configuration' do
    include_context 'with rails configuration'

    let(:subclass) { Class.new(mock_agent_class) }

    before do
      mock_agent_class.extend(described_class::ClassMethods)
      mock_agent_class.send(:apply_rails_configuration, subclass)
    end

    it 'applies provider setting' do
      expect(subclass._provider).to eq(:openai)
    end

    it 'applies model setting' do
      expect(subclass._model).to eq('gpt-5-mini')
    end

    it 'applies api_key setting' do
      expect(subclass._api_key).to eq('test-key')
    end

    it 'applies max_iterations setting' do
      expect(subclass._max_iterations).to eq(10)
    end
  end

  describe '#apply_rails_configuration with partial configuration' do
    let(:configuration) do
      config = Soka::Rails::Configuration.new
      config.ai_provider = :anthropic
      config
    end

    let(:subclass) { Class.new(mock_agent_class) }

    before do
      allow(Soka::Rails).to receive(:configuration).and_return(configuration)
      mock_agent_class.extend(described_class::ClassMethods)
      mock_agent_class.send(:apply_rails_configuration, subclass)
    end

    it 'applies configured provider' do
      expect(subclass._provider).to eq(:anthropic)
    end

    it 'uses default model when not configured' do
      expect(subclass._model).to eq('gemini-2.5-flash-lite')
    end
  end

  describe '#apply_rails_configuration without configuration' do
    let(:subclass) { Class.new(mock_agent_class) }

    before do
      allow(Soka::Rails).to receive(:configuration).and_return(nil)
      mock_agent_class.extend(described_class::ClassMethods)
      mock_agent_class.send(:apply_rails_configuration, subclass)
    end

    it 'does not raise errors' do
      expect(subclass._provider).to be_nil
    end
  end

  describe 'module inclusion' do
    it 'extends Soka::Agent with Rails configuration when included' do
      agent_class = Class.new
      stub_const('Soka::Agent', agent_class)

      load File.expand_path('../../../lib/soka/rails/agent_extensions.rb', __dir__)

      expect(agent_class.included_modules).to include(described_class)
    end

    it 'does not raise error when Soka::Agent is not defined' do
      hide_const('Soka::Agent')

      expect do
        load File.expand_path('../../../lib/soka/rails/agent_extensions.rb', __dir__)
      end.not_to raise_error
    end
  end
end
