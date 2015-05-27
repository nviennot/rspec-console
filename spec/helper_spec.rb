require 'spec_helper'

describe 'helpers' do
  it 'works' do
    if $rspec2
      helper_hello_world.should == 'ohai :)'
    else
      expect(helper_hello_world).to eq('ohai :)')
    end
  end
end

describe 'singleton methods' do
  it 'works' do
    if $rspec2
      RSpec.configuration.some_config_method.should == 'yay'
    else
      expect(RSpec.configuration.some_config_method).to eq('yay')
    end
  end
end
