module RSpecConsole
  # We have to reset the RSpec.configuration, because it contains a lot of
  # information related to the current test (what's running, what are the
  # different test results, etc).
  #
  # RSpec.configuration gets also loaded with a bunch of stuff from the
  # 'spec/spec_helper.rb' file. Often that instance is extended with other
  # modules (FactoryGirl, Mocha,...) and we don't want to replace requires with
  # load all around the place.
  #
  # Instead, we cache whatever is done to RSpec.configuration during the
  # first invokration of require('spec_helper').
  # This is done by interposing the Proxy class on top of RSpec.configuration.
  class ConfigCache
    attr_accessor :config_copy, :recorded_registry

    def cache
      if have_recording?
        ::RSpec.configure(&replay_recorded_config)
        replay_shared_examples unless shared_examples.empty?
      else # record
        original_config = ::RSpec.configuration
        self.config_copy = RSpecConsole::Proxy.new(original_config)

        ::RSpec.configuration = self.config_copy

        yield # spec helper is called during this yield, see #reset

        ::RSpec.configuration = original_config

        record_shared_examples
      end
      forwarding_address_for(::RSpec.configuration.singleton_class, self.config_copy)
    end

    private

    def record_shared_examples
      if rspec_over_3?
        self.recorded_registry = ::RSpec.world.
          shared_example_group_registry.dup rescue nil
      else
        self.recorded_registry = ::RSpec.world.
          shared_example_groups.dup rescue nil
      end
    end

    def forwarding_address_for(rspec_config, config_copy)
      rspec_config.send(:define_method, :method_missing) do |method, *args, &block|
      # note this is not called until runtime when a method is not found on RSpec.configuration
      config_copy.send(method, *args, &block)
      end
    end

    def replay_shared_examples
      # RSpec 2 and 3 have different APIs for accessing shared_examples. 3 has
      # the concept of a "registry" whereas 2 does not.
      if rspec_over_3?
        ::RSpec.world.
          shared_example_group_registry.
          add(
            :main,
            shared_examples.keys.first,
            &shared_examples.values.first
        )
      else
        ::RSpec.world.
          shared_example_groups.merge!(shared_examples || {}) rescue nil
      end
    end

    def rspec_over_3?
      version >= Gem::Version.new('3')
    end

    def replay_recorded_config
      Proc.new do |config|
        config_copy.persisted_config.each do |msg|
          config.send(msg[:method], *msg[:args], &msg[:block])
        end
      end
    end

    def have_recording?
      self.config_copy
    end

    def shared_examples
      recorded_registry.
        send(:shared_example_groups)[:main] rescue recorded_registry
    end

    def version
      Gem.loaded_specs['rspec-core'].version
    end
  end
end
