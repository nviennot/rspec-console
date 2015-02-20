module RSpecConsole::Pry
  def self.setup
    ::Pry::CommandSet.new(&rspec_command).
      tap { |cmd| ::Pry::Commands.import cmd }
  end

  def self.rspec_command
    Proc.new do
      create_command "rspec", "Runs specs; to silence ActiveRecord output use SILENCE_AR=true" do
        group "Testing"

        def process(*args)
          if defined?(ActiveRecord) && ENV['SILENCE_AR'] == true
            # Silence active record logger while running rspec from console
            old_logger = ActiveRecord::Base.logger
            ActiveRecord::Base.logger = Logger.new("#{Rails.root}/log/test.log")
          end

          RSpecConsole::Runner.run(args)

          if defined?(ActiveRecord) && ENV['SILENCE_AR'] == true
            # Restore default logger
            ActiveRecord::Base.logger = old_logger
          end
        end

        def complete(input)
          super + Bond::Rc.files(input.split(" ").last || '')
        end
      end
    end
  end

  private_class_method :rspec_command
end
