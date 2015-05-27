require 'spec_helper'

describe 'fail' do
  it 'fail 1' do
    $rspec.fail1
    raise
  end
end
