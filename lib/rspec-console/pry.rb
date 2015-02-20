module RSpecConsole::Pry
  def self.setup
    ::Pry::CommandSet.new(&method(:rspec_command))
      .tap { |cmd| ::Pry::Commands.import cmd }
  end

  def self.rspec_command(cmd)
    cmd.create_command "rspec", "Runs specs; to silence ActiveRecord output use SILENCE_AR=true" do
      group "Testing"

      def process(*args)
        with_ar_silenced { RSpecConsole::Runner.run(args) }
      end

      def with_ar_silenced(&block)
        return block.call unless defined?(ActiveRecord) && ENV['SILENCE_AR']
        old_logger, ActiveRecord::Base.logger = ActiveRecord::Base.logger, nil
        block.call
      ensure
        ActiveRecord::Base.logger = old_logger
      end

      def complete(input)
        require 'bond'
        super + Bond::Rc.files(input.split(" ").last || '')
      end
    end
  end
end
