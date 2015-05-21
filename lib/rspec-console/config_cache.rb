class RSpecConsole::ConfigCache
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
  #
  attr_accessor :proxy, :recorded_config, :recorded_registry, :version

  def initialize
    ::RSpec.instance_eval do
      def self.configuration=(value)
        @configuration = value
      end
    end
    @recorded_config = []
    @version = Gem.loaded_specs['rspec-core'].version
  end

  def cache
    if self.proxy
      # replay
      ::RSpec.configure do |config|
        self.recorded_config.each do |msg|
          config.send(msg[:method], *msg[:args], &msg[:block])
        end
      end

      if version >= Gem::Version.new('3')
        # we only need what was sent to "main"
        recorded_examples = recorded_registry.send(:shared_example_groups)[:main] rescue nil
        if recorded_examples.present?
          ::RSpec.world.shared_example_group_registry.add(:main,
                                                          recorded_examples.keys.first,
                                                          &recorded_examples.values.first)
        end
      else
        ::RSpec.world.shared_example_groups.merge!(self.shared_examples_groups || {}) rescue nil
      end
    else
      # record
      real_config = ::RSpec.configuration

      self.proxy = Proxy.new(self.recorded_config, real_config)

      ::RSpec.configuration = self.proxy

      # spec helper is called during this yield, see #reset
      yield

      ::RSpec.configuration = real_config

      if version >= Gem::Version.new('3')
        recorded_registry = ::RSpec.world.shared_example_group_registry.dup rescue nil
      else
        recorded_registry = ::RSpec.world.shared_example_groups.dup rescue nil
      end

      # TODO
      # rspec-rails/lib/rspec/rails/view_rendering.rb add methods on the
      # configuration singleton. Need advice to copy them without going down
      # the road with object2module.
    end

    # Well, instead of copying them, we redirect them to the configuration
    # proxy. Looks like it's good enough.
    proxy = self.proxy

    ::RSpec.configuration.singleton_class.send(:define_method, :method_missing) do |method, *args, &block|
      proxy.send(method, *args, &block)
    end
  end
end

class Proxy < Struct.new(:output, :target)
  [:include, :extend].each do |method|
    define_method(method) do |*args|
      method_missing(method, *args)
    end
  end

  def method_missing(method, *args, &block)
    self.output << {method: method, args: args, block: block}
    self.target.send(method, *args, &block)
  end
end

# For compatibility with Ruby 1.8.x outside of the Rails framework
if RUBY_VERSION =~ /1.8/
  unless defined?(Rails)
    class Object
      def singleton_class
        class << self; self; end
      end
    end
  end
end
