module RSpecConsole
  autoload :ConfigCache,    'rspec-console/config_cache'
  autoload :RSpecState,     'rspec-console/rspec_state'
  autoload :Runner,         'rspec-console/runner'
  autoload :Pry,            'rspec-console/pry'

  class << self; attr_accessor :before_run_callbacks; end
  self.before_run_callbacks = []

  def self.run(*args)
    Runner.run(args)
  end

  def self.before_run(&hook)
    self.before_run_callbacks << hook
  end

  Pry.setup if defined?(::Pry)

  # We only want the test env
  before_run do
    if defined?(Rails) && !Rails.env =~ /test/
      raise 'Please run in test mode (run `rails console test`).'
    end
  end

  # Emit warning when reload cannot be called, or call reload!
  before_run do
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

          Otherwise, code relading does not work.
        MSG
      else
        ActionDispatch::Reloader.cleanup!
        ActionDispatch::Reloader.prepare!
      end
    end
  end

  # Reloading FactoryGirl if necessary
  before_run { FactoryGirl.reload if defined?(FactoryGirl) }
end
