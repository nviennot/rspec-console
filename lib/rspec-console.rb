module RSpecConsole
  autoload :ConfigCache, 'rspec-console/config_cache'
  autoload :Environment, 'rspec-console/environment'
  autoload :Proxy,       'rspec-console/proxy'
  autoload :Runner,      'rspec-console/runner'
  autoload :Pry,         'rspec-console/pry'

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
      raise "Rails env must be set as test (use `rails console test` to launch the console)."
    end
  end

  # Emit warning when reload cannot be called, or call reload!
  register_hook do
    if defined?(Rails)
      if Rails.application.config.cache_classes
        STDERR.puts <<-MSG
[WARNING]
Rails's cache_classes must be turned off.
Turn off in config/environments/test.rb:

  Rails.application.configure do
    conig.cache_classes = false
  end
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
