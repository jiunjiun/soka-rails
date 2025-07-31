# frozen_string_literal: true

RSpec.shared_context 'with mocked environment variables' do
  let(:env_vars) { {} }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    env_vars.each do |key, value|
      allow(ENV).to receive(:fetch).with(key, anything).and_return(value)
    end
  end
end

RSpec.shared_context 'with rails configuration' do
  let(:configuration) do
    config = Soka::Rails::Configuration.new
    config.ai_provider = :openai
    config.ai_model = 'gpt-4'
    config.ai_api_key = 'test-key'
    config.max_iterations = 10
    config.timeout = 30
    config
  end

  before do
    allow(Soka::Rails).to receive(:configuration).and_return(configuration)
  end
end
