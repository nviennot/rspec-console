require 'test_helper'

class BasicTest < Minitest::Test
  def test_simple
    rspec_run('spec/simple_spec.rb')
    assert_rspec_methods [:config_before_all, :test1, :test2]
    assert_rspec_output :examples => 2
  end

  def test_multiple
    rspec_run('spec/simple_spec.rb:4')
    assert_rspec_methods [:config_before_all, :test1]
    assert_rspec_output :examples => 1

    rspec_run('spec/simple_spec.rb:8')
    assert_rspec_methods [:config_before_all, :test2]
    assert_rspec_output :examples => 1

    rspec_run('spec/simple_spec.rb:4', 'spec/simple_spec.rb:8')
    assert_rspec_methods [:config_before_all, :test1, :test2]
    assert_rspec_output :examples => 2
  end

  def test_helper
    rspec_run('spec/helper_spec.rb:3')
    assert_rspec_output :examples => 1
  end

  def test_singleton
    rspec_run('spec/helper_spec.rb:9')
    assert_rspec_output :examples => 1
  end

  def test_shared_examples
    rspec_run('spec/shared_examples_spec.rb')
    assert_rspec_output :examples => 6
  end

  def test_fail
    rspec_run('spec/fail_spec.rb')
    assert_rspec_methods [:config_before_all, :fail1]
    assert_rspec_output :examples => 1, :failures => 1
  end

  def test_all
    rspec_run()
    assert_rspec_output :examples => 11, :failures => 1
  end
end
