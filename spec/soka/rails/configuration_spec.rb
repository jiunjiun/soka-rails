# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Soka::Rails::Configuration do
  subject(:config) { described_class.new }

  describe 'default configuration' do
    it_behaves_like 'a configurable setting', :ai_provider, :gemini, :openai
    it_behaves_like 'a configurable setting', :ai_model, 'gemini-2.5-flash-lite', 'gpt-5-mini'
    it_behaves_like 'a configurable setting', :ai_api_key, nil, 'test-key'
  end

  describe '#max_iterations' do
    context 'when Rails is not in production' do
      it 'defaults to 5' do
        expect(config.max_iterations).to eq(5)
      end
    end

    context 'when Rails is in production' do
      let(:rails_class) do
        Class.new do
          def self.env
            @env ||= Struct.new(:production?) do
              def production?
                true
              end
            end.new
          end
        end
      end

      before do
        stub_const('::Rails', rails_class)
      end

      it 'defaults to 10' do
        expect(described_class.new.max_iterations).to eq(10)
      end
    end
  end

  describe 'environment variable configuration' do
    include_context 'with mocked environment variables'

    let(:env_vars) do
      {
        'SOKA_PROVIDER' => 'openai',
        'SOKA_MODEL' => 'gpt-5-mini',
        'SOKA_API_KEY' => 'env-test-key'
      }
    end

    it 'loads ai_provider from environment' do
      expect(described_class.new.ai_provider).to eq(:openai)
    end

    it 'loads ai_model from environment' do
      expect(described_class.new.ai_model).to eq('gpt-5-mini')
    end

    it 'loads ai_api_key from environment' do
      expect(described_class.new.ai_api_key).to eq('env-test-key')
    end
  end

  describe 'DSL configuration' do
    it_behaves_like 'a DSL configuration', :ai, Soka::Rails::Configuration::AIConfig
    it_behaves_like 'a DSL configuration', :performance, Soka::Rails::Configuration::PerformanceConfig
  end

  describe '#ai DSL' do
    before do
      config.ai do |ai|
        ai.provider = :anthropic
        ai.model = 'claude-sonnet-4-0'
        ai.api_key = 'claude-key'
      end
    end

    it 'sets provider through DSL' do
      expect(config.ai_provider).to eq(:anthropic)
    end

    it 'sets model through DSL' do
      expect(config.ai_model).to eq('claude-sonnet-4-0')
    end

    it 'sets api_key through DSL' do
      expect(config.ai_api_key).to eq('claude-key')
    end
  end

  describe '#performance DSL' do
    before do
      config.performance do |perf|
        perf.max_iterations = 20
      end
    end

    it 'sets max_iterations' do
      expect(config.max_iterations).to eq(20)
    end
  end
end
