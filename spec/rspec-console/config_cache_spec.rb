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

  # to support behavior I saw but couldn't reason out
  describe "#initialize" do
    it "makes ::RSpec.configuration writable" do
      expect(::RSpec.respond_to?(:configuration=)).to eq(true)
    end
  end

  describe "#cache" do
    it "creates a proxy on first run" do
      expect(RSpecConsole::Proxy).to receive(:new).and_call_original
      config_cache.cache &config_block
    end
    it "delegates through proxy on repeated runs" do
      config_cache.cache &config_block
      expect(RSpecConsole::Proxy).to_not receive(:new)
      config_cache.cache &config_block
    end
    it "uses RSpec #add if version 3+ and shared_examples exist" do
      expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:have_recording?).
        and_return(true)
      expect(::RSpec).to receive(:configure).and_return(nil)
      expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:version).
        and_return(Gem::Version.new('3.1.4'))
      expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:shared_examples).
        exactly(3).times.
        and_return(
          double('shared_examples',
                 empty?: false,
                 keys: ["method_name"],
                 values: [Proc.new{}]))
      config_cache.cache &config_block
    end
    it "simply merges in the recorded examples if RSpec 2" do
      expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:have_recording?).
        and_return(true)
      expect(::RSpec).to receive(:configure).and_return(nil)
      expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:version).
        and_return(Gem::Version.new('2.10.9'))
      expect(::RSpec).to receive_message_chain(:world, :shared_example_groups, :merge!).
        with({})
      config_cache.cache &config_block
    end
    it "defines method_missing method on RSpec.configuration's singleton class" do
      config_cache.cache &config_block
      expect(RSpec.configuration.respond_to?(:method_missing)).to eq(true)
    end
  end
end
