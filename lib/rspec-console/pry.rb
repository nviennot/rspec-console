module RSpecConsole::Pry
  def self.setup
    ::Pry::CommandSet.new do
      create_command "rspec", "Works pretty much like the regular rspec command" do
        group "Testing"

        def process(*args)
          RSpecConsole::Runner.run(args)
        end

        def complete(input)
          require 'bond'
          super + Bond::Rc.files(input.split(" ").last || '')
        end
      end
    end.tap { |cmd| ::Pry::Commands.import cmd }
  end
end
