class RSpecConsole::Runner
  class << self
    def reset(args)
      require 'rspec/core'

      if Gem.loaded_specs['rspec-core'].version < Gem::Version.new('2.9.10')
        raise 'Please use RSpec 2.9.10 or later'
      end

      ::RSpec::Core::Runner.disable_autorun!
      ::RSpec::Core::Configuration.class_eval { define_method(:command) { 'rspec' } }

      if ::RSpec::Core::Version::STRING >= "3.0.0"
        ::RSpec.world.reset
        ::RSpec.configuration.reset
      else
        ::RSpec.reset

        config_cache.cache do
          ::RSpec.configure do |config|
            config.output_stream = STDOUT
            config.color         = true
          end

          require "./spec/spec_helper"
        end
      end
    end

    def run(args)
      RSpecConsole.hooks.each(&:call)
      reset(args)
      if ::RSpec::Core::Version::STRING >= "3.0.0"
        ::RSpec::Core::Runner.run(args)
      else
        ::RSpec::Core::CommandLine.new(args).run(STDERR, STDOUT)
      end
    end

    def config_cache
      @config_cache ||= RSpecConsole::ConfigCache.new
    end
  end
end
