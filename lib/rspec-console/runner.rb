class RSpecConsole::Runner
  class << self
    def reset(args)
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
          config.color_enabled = true
        end

        require "./spec/spec_helper"
      end
    end

    def _run(args)
      reset(args)
      ::RSpec::Core::CommandLine.new(args).run(STDERR, STDOUT)
    end

    def run(args)
      if defined?(Rails)
        warn_cache_classes if turn_on_cache_classes?
        _run(args)
      else
        _run(args)
      end
    end

    def config_cache
      @config_cache ||= RSpecConsole::ConfigCache.new
    end

    private

    def turn_on_cache_classes?
      Rails.application.config.cache_classes
    end

    def warn_cache_classes
      STDERR.puts <<-MSG
WARNING: Rails's cache_classes must to be turn off.

Turn off in config/environments/test.rb as:

  Rails.application.configure do
    conig.cache_classes = false
  end

      MSG
    end
  end
end
