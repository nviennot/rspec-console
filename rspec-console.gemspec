# encoding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

require 'rspec-console/version'

Gem::Specification.new do |s|
  s.name        = "rspec-console"
  s.version     = RSpecConsole::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nicolas Viennot"]
  s.email       = ["nicolas@viennot.biz"]
  s.homepage    = "http://github.com/nviennot/rspec-console"
  s.summary     = "Run RSpec tests in your console"
  s.description = "Run RSpec tests in your console"
  s.license     = "MIT"

  s.add_dependency 'bond'
  s.add_development_dependency 'rspec'

  s.files        = Dir["lib/**/*"] + ['README.md']
  s.require_path = 'lib'
  s.has_rdoc     = false
end
