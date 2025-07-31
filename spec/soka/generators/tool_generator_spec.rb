# frozen_string_literal: true

require 'spec_helper'

# Skip generator tests if Rails is not loaded
if defined?(Rails::Generators)
  require 'tmpdir'
  require 'generators/soka/tool/tool_generator'
  require_relative '../../support/generator_helpers'

  RSpec.describe Soka::Generators::ToolGenerator, type: :generator do
    include GeneratorHelpers

    before do
      prepare_destination
      stub_rails_root
      allow(generator).to receive(:rspec_installed?).and_return(true)
    end

    after do
      FileUtils.rm_rf(destination_root)
    end

    context 'when generating a simple tool' do
      let(:generator) { described_class.new(['weather_api']) }

      describe '#create_tool_file' do
        it 'creates tool file with correct name' do
          generator.create_tool_file
          expect(File).to exist(File.join(destination_root, 'app/soka/tools/weather_api_tool.rb'))
        end

        it 'creates tool with correct class name' do
          generator.create_tool_file
          content = File.read(File.join(destination_root, 'app/soka/tools/weather_api_tool.rb'))
          expect(content).to include('class WeatherApiTool')
        end
      end

      describe '#create_test_file' do
        it 'creates spec file with correct name' do
          generator.create_test_file
          expect(File).to exist(File.join(destination_root, 'spec/soka/tools/weather_api_tool_spec.rb'))
        end
      end
    end

    context 'when generating tool with parameters' do
      let(:generator) { described_class.new(['weather_api', 'location:string', 'units:string']) }

      it 'includes parameters in the generated tool' do
        generator.create_tool_file
        content = File.read(File.join(destination_root, 'app/soka/tools/weather_api_tool.rb'))
        expect(content).to include('parameter :location, :string').and include('parameter :units, :string')
      end
    end

    context 'when name already includes _tool suffix' do
      let(:generator) { described_class.new(['weather_api_tool']) }

      it 'does not duplicate _tool suffix' do
        generator.create_tool_file
        expect(File).to exist(File.join(destination_root, 'app/soka/tools/weather_api_tool.rb'))
      end

      it 'creates tool with correct class name without duplication' do
        generator.create_tool_file
        content = File.read(File.join(destination_root, 'app/soka/tools/weather_api_tool.rb'))
        expect(content).to include('class WeatherApiTool').and not_include('class WeatherApiToolTool')
      end
    end

    context 'when rspec is not installed' do
      let(:generator) { described_class.new(['test']) }

      before do
        allow(generator).to receive(:rspec_installed?).and_return(false)
      end

      it 'does not create test file' do
        generator.create_test_file
        expect(File).not_to exist(File.join(destination_root, 'spec/soka/tools/test_tool_spec.rb'))
      end
    end
  end
else
  RSpec.describe 'Soka::Generators::ToolGenerator' do
    it 'requires Rails generators to be loaded' do
      skip 'Rails generators are not available in this test environment'
    end
  end
end
