require "spec_helper"

describe RSpecConsole::ConfigCache do
  let(:config_cache) do
    described_class.new
  end
  let(:config_block) do
    Proc.new do
      ::RSpec.configure do |config|
        config.output_stream = STDOUT
      end
    end
  end

  describe "#cache" do
    it "creates a proxy on first run" do
      expect(Proxy).to receive(:new).and_call_original
      config_cache.cache &config_block
    end
    it "delegates through proxy on repeated runs" do
      config_cache.cache &config_block
      expect(Proxy).to_not receive(:new)
      config_cache.cache &config_block
    end
    it "defines method_missing method on RSpec.configuration's singleton class" do
      config_cache.cache &config_block
      expect(RSpec.configuration.respond_to?(:method_missing)).to eq(true)
    end
  end
end
