module RSpecConsole
  autoload :ConfigCache, 'rspec-console/config_cache'
  autoload :Runner,      'rspec-console/runner'
  autoload :Pry,         'rspec-console/pry'

  def self.run(*args)
    Runner.run(args)
  end

  Pry.setup if defined?(::Pry)
end
