module RSpecConsole
  class VersionError < StandardError
    def to_s
      'Please use RSpec 2.9.10 or later'
    end
  end
  class RailsEnvError < StandardError
    def to_s
      'Rails env must be set as test (use `rails console test` to launch the console).'
    end
  end
end
