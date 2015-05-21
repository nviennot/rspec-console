require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../", __FILE__)
require "rspec-console"
require "pry"

RSpec.configure do |config|
end
