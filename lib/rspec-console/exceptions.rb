module RSpecConsole
  class VersionError < StandardError
    'Please use RSpec 2.9.10 or later'
  end
  class RailsEnvError < StandardError
    'Rails env must be set as test (use `rails console test` to launch the console).'
  end
end
