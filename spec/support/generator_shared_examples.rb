# frozen_string_literal: true

RSpec.shared_examples 'a rails generator' do
  it 'inherits from Rails::Generators::Base or NamedBase' do
    expect(described_class.ancestors).to include(Rails::Generators::Base)
  end

  it 'has a source root' do
    expect(described_class).to respond_to(:source_root)
  end
end

RSpec.shared_examples 'creates file from template' do |method_name, destination_path|
  describe "##{method_name}" do
    it "creates #{File.basename(destination_path)}" do
      generator.public_send(method_name)
      expect(File).to exist(File.join(destination_root, destination_path))
    end

    it 'creates non-empty file' do
      generator.public_send(method_name)
      content = File.read(File.join(destination_root, destination_path))
      expect(content).not_to be_empty
    end
  end
end

RSpec.shared_examples 'optional test file creation' do |method_name, test_path|
  describe "##{method_name}" do
    context 'when RSpec is installed' do
      before { allow(generator).to receive(:rspec_installed?).and_return(true) }

      it 'creates test file' do
        generator.public_send(method_name)
        expect(File).to exist(File.join(destination_root, test_path))
      end
    end

    context 'when RSpec is not installed' do
      before { allow(generator).to receive(:rspec_installed?).and_return(false) }

      it 'does not create test file' do
        generator.public_send(method_name)
        expect(File).not_to exist(File.join(destination_root, test_path))
      end
    end
  end
end
