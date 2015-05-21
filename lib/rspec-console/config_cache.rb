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
# RSpec 2 and 3 have different APIs for accessing shared_examples. 3 has
# the concept of a "registry" whereas 2 does not.
class RSpecConsole::ConfigCache
  attr_accessor :proxy, :recorded_registry, :version

  def initialize
    # allow writing to configuration
    ::RSpec.instance_eval do
      def self.configuration=(value)
        @configuration = value
      end
    end
    @version = Gem.loaded_specs['rspec-core'].version
  end

  def cache
    if have_recording?
      ::RSpec.configure &replay_recorded_config

      if version >= Gem::Version.new('3')
        recorded_examples = recorded_registry.send(:shared_example_groups)[:main] rescue nil

        unless recorded_examples.nil?
          ::RSpec.world.shared_example_group_registry.add(:main,
                                                          recorded_examples.keys.first,
                                                          &recorded_examples.values.first)
        end
      else
        ::RSpec.world.shared_example_groups.merge!(recorded_registry || {}) rescue nil
      end
    else
      # record
      original_config = ::RSpec.configuration

      # Proxy output, target
      self.proxy = Proxy.new([], original_config)

      ::RSpec.configuration = self.proxy

      # spec helper is called during this yield, see #reset
      yield

      ::RSpec.configuration = original_config

      if version >= Gem::Version.new('3')
        self.recorded_registry = ::RSpec.world.shared_example_group_registry.dup rescue nil
      else
        self.recorded_registry = ::RSpec.world.shared_example_groups.dup rescue nil
      end

      # TODO
      # rspec-rails/lib/rspec/rails/view_rendering.rb add methods on the
      # configuration singleton. Need advice to copy them without going down
      # the road with object2module.
    end

    # Well, instead of copying them, we redirect them to the configuration
    # proxy. Looks like it's good enough.
    # delegating to the proxy when we're missing a method
    ::RSpec.configuration.singleton_class.send(:define_method, :method_missing) do |method, *args, &block|
      self.proxy.send(method, *args, &block)
    end
  end

  private
  def replay_recorded_config
    Proc.new do |config|
      self.proxy.output.each do |msg|
        config.send(msg[:method], *msg[:args], &msg[:block])
      end
    end
  end
  def have_recording?
    self.proxy
  end
end

# Proxy is really the recorder
class Proxy < Struct.new(:output, :target)
  [:include, :extend].each do |method|
    define_method(method) do |*args|
      method_missing(method, *args)
    end
  end

  def method_missing(method, *args, &block)
    self.output << { method: method, args: args, block: block }
    self.target.send(method, *args, &block)
  end
end
