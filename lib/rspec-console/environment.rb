class RSpecConsole::Environment
  class << self
    def reset
      require 'rspec/core'
      raise VersionError if under_version_2_9?

      ::RSpec::Core::Runner.disable_autorun!
      ::RSpec::Core::Configuration.class_eval { define_method(:command) { 'rspec' } }
      ::RSpec.reset

      config_cache.cache &default_config_block
    end

    private
    def config_cache
      @config_cache ||= RSpecConsole::ConfigCache.new
    end

    def default_config_block
      Proc.new do
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

    def under_version_2_9?
      Gem.loaded_specs['rspec-core'].version < Gem::Version.new('2.9.10')
    end
  end
end
