# This class wraps the core rspec runner and manages the environment around it.
module RSpecConsole
  class Runner
    class << self
      def run(args, options={})
        RSpecConsole.before_run_callbacks.each(&:call)

        RSpecConsole::RSpecState.reset

        stdout = options[:stdout] || $stdout
        stderr = options[:stderr] || $stderr

        ::RSpec::Core::Runner.run(args, stderr, stdout)
      end
    end
  end
end
