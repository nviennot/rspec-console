# This is a fixture for the tests
# This is *not* the actual tests for rspec-console (see in ./test)

RSpec.configure do |config|
  config.before(:all) { $rspec.config_before_all }
end

module SomeHelper
  def helper_hello_world
    'ohai :)'
  end

  RSpec.configure { |config| config.include self }
end

RSpec.configure do |config|
  def config.some_config_method
    'yay'
  end
end

RSpec.shared_examples 'root shared examples' do
  it 'works 1' do
    $rspec.root_shared_examples1
  end

  it 'works 2' do
    $rspec.root_shared_examples2
  end
end

$rspec2 = Gem.loaded_specs['rspec-core'].version < Gem::Version.new('3')
