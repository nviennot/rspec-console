require 'spec_helper'

describe 'some shared examples 1' do
  shared_examples_for 'included shared example' do
    it 'works 1' do
      $rspec.shared_examples11
    end

    it 'works 2' do
      $rspec.shared_examples12
    end
  end

  context 'one' do
    it_behaves_like 'included shared example'
  end

  context 'two' do
    it_behaves_like 'included shared example'
  end

  context 'root' do
    it_behaves_like 'root shared examples'
  end
end

