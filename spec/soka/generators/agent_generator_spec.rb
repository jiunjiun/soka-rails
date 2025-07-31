# frozen_string_literal: true

require 'spec_helper'

if defined?(Rails::Generators)
  require 'tmpdir'
  require 'generators/soka/agent/agent_generator'

  RSpec.describe Soka::Generators::AgentGenerator, type: :generator do
    include GeneratorHelpers

    before do
      prepare_destination
      stub_rails_root
    end

    after do
      FileUtils.rm_rf(destination_root)
    end

    it_behaves_like 'a rails generator'

    describe 'agent generation' do
      let(:generator) { described_class.new(['customer_support']) }

      it_behaves_like 'creates file from template', :create_agent_file,
                      'app/soka/agents/customer_support_agent.rb'

      it_behaves_like 'optional test file creation', :create_test_file,
                      'spec/soka/agents/customer_support_agent_spec.rb'

      describe 'generated agent content' do
        before { generator.create_agent_file }

        let(:content) { File.read(File.join(destination_root, 'app/soka/agents/customer_support_agent.rb')) }

        it 'includes correct class name' do
          expect(content).to include('class CustomerSupportAgent')
        end

        it 'inherits from ApplicationAgent' do
          expect(content).to include('< ApplicationAgent')
        end
      end
    end

    describe 'agent with tools' do
      let(:generator) { described_class.new(%w[weather weather_api location_api]) }
      let(:content) { File.read(File.join(destination_root, 'app/soka/agents/weather_agent.rb')) }

      before { generator.create_agent_file }

      it 'includes all specified tools' do
        expect(content).to include('weather_api', 'location_api')
      end
    end

    describe 'name normalization' do
      context 'when name already includes _agent suffix' do
        let(:generator) { described_class.new(['customer_support_agent']) }

        it 'does not duplicate suffix in file name' do
          generator.create_agent_file
          expect(File).to exist(File.join(destination_root, 'app/soka/agents/customer_support_agent.rb'))
        end

        it 'does not duplicate _agent suffix in file path' do
          generator.create_agent_file
          expect(File).not_to exist(File.join(destination_root, 'app/soka/agents/customer_support_agent_agent.rb'))
        end

        it 'does not duplicate suffix in class name' do
          generator.create_agent_file
          content = File.read(File.join(destination_root, 'app/soka/agents/customer_support_agent.rb'))
          expect(content).to include('class CustomerSupportAgent')
        end

        it 'does not duplicate Agent suffix in generated class' do
          generator.create_agent_file
          content = File.read(File.join(destination_root, 'app/soka/agents/customer_support_agent.rb'))
          expect(content).not_to include('class CustomerSupportAgentAgent')
        end
      end
    end
  end
else
  RSpec.describe 'Soka::Generators::AgentGenerator' do
    it 'requires Rails generators to be loaded' do
      skip 'Rails generators are not available in this test environment'
    end
  end
end
