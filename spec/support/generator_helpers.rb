# frozen_string_literal: true

module GeneratorHelpers
  def self.included(base)
    base.class_eval do
      let(:destination_root) { File.expand_path('../../tmp', __dir__) }

      def prepare_destination
        FileUtils.rm_rf(destination_root)
        FileUtils.mkdir_p(destination_root)
      end
    end
  end

  # Create a fake Rails root for testing
  def stub_rails_root
    return unless defined?(::Rails)

    rails_root = Pathname.new('/tmp/rails_app')
    allow(::Rails).to receive(:root).and_return(rails_root)
  end
end
