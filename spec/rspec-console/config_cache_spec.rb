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
    it "defines method_missing method on RSpec.configuration's singleton class" do
      expect(config_cache).to receive(:config_copy).exactly(3).times
      config_cache.cache(&config_block)
      expect(::RSpec.configuration.respond_to?(:method_missing)).to eq(true)
    end

    it "creates a proxy on first run" do
      expect(RSpecConsole::Proxy).to receive(:new).and_call_original
      config_cache.cache(&config_block)
    end

    it "delegates through proxy on repeated runs" do
      config_cache.cache(&config_block)
      expect(RSpecConsole::Proxy).to_not receive(:new)
      config_cache.cache(&config_block)
    end
  end

  describe "#cache" do
    context "when recording the config" do
      before(:each) do
        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:have_recording?).
          and_return(false)
      end

      it "does a dup of shared example groups" do
        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:version).
          and_return(Gem::Version.new('2.10.9'))

        shared_example_group = double('shared_example_group')
        expect(::RSpec).to receive_message_chain(:world, :shared_example_groups, :dup).
          and_return(shared_example_group)
        config_cache.cache(&config_block)

        expect(config_cache.recorded_registry).to eq(shared_example_group)
      end
    end

    context "with recorded config" do
      before(:each) do
        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:have_recording?).
          and_return(true)
        expect(::RSpec).to receive(:configure).and_return(nil)
      end

      it "uses RSpec #add if version 3+" do
        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:version).
          and_return(Gem::Version.new('3.1.4'))

        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:shared_examples).
          exactly(3).times.
          and_return(
            double('shared_examples',
                   empty?: false,
                   keys: ['method_name'],
                   values: [Proc.new{}]))

        config_cache.cache(&config_block)
      end
      it "simply merges in the recorded examples if RSpec 2" do
        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:version).
          and_return(Gem::Version.new('2.10.9'))
        expect_any_instance_of(RSpecConsole::ConfigCache).to receive(:shared_examples).
          exactly(2).times.
          and_return({})

        expect(::RSpec).to receive_message_chain(:world, :shared_example_groups, :merge!).
          with({})

        config_cache.cache(&config_block)
      end
    end

    context 'interaction with Proxy' do
      let(:customized_config_block) do
        proc do
          ::RSpec.configure do |config|
            config.output_stream = STDOUT
            config.add_setting :bogus_method
          end
        end
      end

      it "sends any methods missing on RSpec.configuration to Proxy" do
        ::RSpec.reset
        expect(::RSpec.configuration.respond_to?(:bogus_method)).to eq false
        config_cache.cache(&customized_config_block)
        expect(::RSpec.configuration.respond_to?(:bogus_method)).to eq true
      end
    end
  end
end
