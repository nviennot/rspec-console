module RSpecConsole
  autoload :ConfigCache, 'rspec-console/config_cache'
  autoload :RSpecLastRunState, 'rspec-console/rspec_last_run_state'
  autoload :Proxy,       'rspec-console/proxy'
  autoload :Runner,      'rspec-console/runner'
  autoload :Pry,         'rspec-console/pry'
  autoload :VersionError,'rspec-console/exceptions'

  class << self; attr_accessor :hooks; end
  self.hooks = []

  def self.run(*args)
    Runner.run(args)
  end

  def self.register_hook(&hook)
    self.hooks << hook
  end

  Pry.setup if defined?(::Pry)

  # We only want the test env
  register_hook do
    if defined?(Rails) && !Rails.env =~ /test/
      fail RSpecConsole::RailsEnvError
    end
  end

  # Emit warning when reload cannot be called, or call reload!
  register_hook do
    class String
      def red
        "\033[31m#{self}\033[0m"
      end
    end
    if defined?(Rails)
      if Rails.application.config.cache_classes
        STDERR.puts <<-MSG.gsub(/^ {10}/, '')
          #{"[ WARNING ]".red }
          Rails's cache_classes must be turned off.
          Turn it off in config/environments/test.rb:

            Rails.application.configure do
              config.cache_classes = false
            end

          see https://github.com/nviennot/rspec-console#2-with-rails-disable-cache_classes-so-reload-function-properly
        MSG
      else
        ActionDispatch::Reloader.cleanup!
        ActionDispatch::Reloader.prepare!
      end
    end
  end

  # Reloading FactoryGirl if necessary
  register_hook { FactoryGirl.reload if defined?(FactoryGirl) }
end
