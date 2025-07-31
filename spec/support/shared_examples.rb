# frozen_string_literal: true

RSpec.shared_examples 'a configurable setting' do |setting_name, default_value, new_value|
  describe "##{setting_name}" do
    it "has default value of #{default_value}" do
      expect(subject.public_send(setting_name)).to eq(default_value)
    end

    it 'can be updated' do
      subject.public_send("#{setting_name}=", new_value)
      expect(subject.public_send(setting_name)).to eq(new_value)
    end
  end
end

RSpec.shared_examples 'a DSL configuration' do |dsl_method, config_class|
  describe "##{dsl_method}" do
    it "yields #{config_class} instance" do
      expect { |b| subject.public_send(dsl_method, &b) }
        .to yield_with_args(config_class)
    end
  end
end
