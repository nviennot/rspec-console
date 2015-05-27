module RSpecConsole
  class RSpecState
    class << self
      def reset
        require 'rspec/core'
        raise 'Please use RSpec 2.10.0 or later' if obsolete_rspec?

        ::RSpec::Core::Runner.disable_autorun!
        ::RSpec.reset

        if config_cache.has_recorded_config?
          config_cache.replay_configuration
        else
          config_cache.record_configuration(&rspec_configuration)
        end
      end

      def rspec_configuration
        proc do
          ::RSpec.configure do |config|
            config.color_enabled = true if config.respond_to?(:color_enabled=)
            config.color         = true if config.respond_to?(:color=)
          end

          $LOAD_PATH << './spec'
          try_load('spec_helper')
          try_load('rails_helper')
        end
      end

      def try_load(file)
        begin
          require file
        rescue LoadError
        end
      end

      def config_cache
        @config_cache ||= RSpecConsole::ConfigCache.new
      end

      def obsolete_rspec?
        Gem.loaded_specs['rspec-core'].version < Gem::Version.new('2.10.0')
      end
    end
  end
end
