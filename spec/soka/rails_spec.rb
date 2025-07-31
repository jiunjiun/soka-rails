# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Soka::Rails do
  describe '.configure' do
    after { described_class.instance_variable_set(:@configuration, nil) }

    it 'provides configuration DSL' do
      expect(described_class).to respond_to(:configure)
    end

    it 'yields configuration instance' do
      expect { |b| described_class.configure(&b) }
        .to yield_with_args(Soka::Rails::Configuration)
    end

    context 'with AI configuration' do
      before do
        described_class.configure do |config|
          config.ai do |ai|
            ai.provider = :openai
            ai.model = 'gpt-4'
            ai.api_key = 'test-key'
          end
        end
      end

      it 'persists provider configuration' do
        expect(described_class.configuration.ai_provider).to eq(:openai)
      end

      it 'persists model configuration' do
        expect(described_class.configuration.ai_model).to eq('gpt-4')
      end

      it 'persists api_key configuration' do
        expect(described_class.configuration.ai_api_key).to eq('test-key')
      end
    end

    context 'with multiple configuration calls' do
      before do
        described_class.configure do |config|
          config.ai { |ai| ai.provider = :openai }
        end

        described_class.configure do |config|
          config.ai { |ai| ai.model = 'gpt-4' }
        end
      end

      it 'preserves provider from first call' do
        expect(described_class.configuration.ai_provider).to eq(:openai)
      end

      it 'preserves model from second call' do
        expect(described_class.configuration.ai_model).to eq('gpt-4')
      end
    end
  end

  describe '.configuration' do
    it 'returns the same configuration instance' do
      first_call = described_class.configuration
      second_call = described_class.configuration
      expect(first_call).to be(second_call)
    end

    it 'creates configuration instance' do
      expect(described_class.configuration).to be_a(Soka::Rails::Configuration)
    end

    it 'uses default provider when not configured' do
      expect(described_class.configuration.ai_provider).to eq(:gemini)
    end
  end
end
