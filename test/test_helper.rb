require 'bundler'
Bundler.require

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'

puts "Testing with rspec version #{Gem.loaded_specs['rspec-core'].version}"


class Minitest::Test
  class CatchAll < Struct.new(:messages)
    def initialize
      self.messages = []
    end

    def method_missing(method, *args, &block)
      messages << [method.to_sym, args, block]
    end

    def methods_called
      messages.map { |method, args, block| method }
    end
  end

  def rspec_run(*args)
    stdout = StringIO.new
    @rspec = $rspec = CatchAll.new
    RSpecConsole::Runner.run(args, :stdout => stdout, :stderr => stdout)
  ensure
    @stdout = stdout.tap { |s| s.rewind }.read
  end

  def assert_rspec_output(options={})
    options[:failures] ||= 0
    assert_match(/Finished.*#{options[:examples]} example.*#{options[:failures]} failure/m, @stdout)
  end


  def assert_rspec_methods(methods)
    assert_equal(methods, @rspec.methods_called)
  end
end
