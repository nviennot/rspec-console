# This class wraps the core rspec runner and manages the environment around it.
class RSpecConsole::Runner
  class << self
    def run(args)
      RSpecConsole.hooks.each(&:call)

      RSpecConsole::RSpecLastRunState.reset

      if defined?(::RSpec::Core::CommandLine)
        ::RSpec::Core::CommandLine.new(args).run(STDERR, STDOUT)
      else
        ::RSpec::Core::Runner.run(args, STDERR, STDOUT)
      end
    end
  end
end
