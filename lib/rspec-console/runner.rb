class RSpecConsole::Runner
  class << self
    def run(args)
      RSpecConsole.hooks.each(&:call)
      reset_environment
      if defined?(::RSpec::Core::CommandLine)
        ::RSpec::Core::CommandLine.new(args).run(STDERR, STDOUT)
      else
        ::RSpec::Core::Runner.run(args, STDERR, STDOUT)
      end
    end

    def reset_environment
      require 'rspec/core'

      if Gem.loaded_specs['rspec-core'].version < Gem::Version.new('2.9.10')
        raise 'Please use RSpec 2.9.10 or later'
      end

      ::RSpec::Core::Runner.disable_autorun!
      ::RSpec::Core::Configuration.class_eval { define_method(:command) { 'rspec' } }
      ::RSpec.reset

      config_cache.cache do
        ::RSpec.configure do |config|
          config.output_stream = STDOUT
          config.color_enabled = true if config.respond_to?(:color_enabled=)
          config.color         = true if config.respond_to?(:color=)
        end

        $LOAD_PATH << './spec'
        require "spec_helper"
        begin
          require "rails_helper"
        rescue LoadError
        end
      end
    end

    private
    def config_cache
      @config_cache ||= RSpecConsole::ConfigCache.new
    end
  end
end
