# frozen_string_literal: true

require 'spec_helper'

# Skip generator tests if Rails is not loaded
if defined?(Rails::Generators)
  require 'tmpdir'
  require 'generators/soka/install/install_generator'
  require_relative '../../support/generator_helpers'

  RSpec.describe Soka::Generators::InstallGenerator, type: :generator do
    include GeneratorHelpers

    before do
      prepare_destination
      allow(generator).to receive(:say)
    end

    after do
      FileUtils.rm_rf(destination_root)
    end

    let(:generator) { described_class.new }

    describe '#create_initializer' do
      it 'creates soka.rb initializer' do
        generator.create_initializer
        expect(File).to exist(File.join(destination_root, 'config/initializers/soka.rb'))
      end
    end

    describe '#create_application_agent' do
      it 'creates application_agent.rb' do
        generator.create_application_agent
        expect(File).to exist(File.join(destination_root, 'app/soka/agents/application_agent.rb'))
      end
    end

    describe '#create_application_tool' do
      it 'creates application_tool.rb' do
        generator.create_application_tool
        expect(File).to exist(File.join(destination_root, 'app/soka/tools/application_tool.rb'))
      end
    end

    describe '#add_soka_directory' do
      it 'creates soka directories' do
        generator.add_soka_directory
        expect(File).to exist(File.join(destination_root, 'app/soka'))
          .and exist(File.join(destination_root, 'app/soka/agents'))
          .and exist(File.join(destination_root, 'app/soka/tools'))
      end
    end

    describe '#display_post_install_message' do
      it 'displays installation success message' do
        allow(generator).to receive(:say)
        generator.display_post_install_message
        expect(generator).to have_received(:say).with("\nSoka Rails has been successfully installed!", :green)
      end
    end
  end
else
  RSpec.describe 'Soka::Generators::InstallGenerator' do
    it 'requires Rails generators to be loaded' do
      skip 'Rails generators are not available in this test environment'
    end
  end
end
