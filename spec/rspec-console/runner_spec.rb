require "spec_helper"

describe RSpecConsole::Runner do
  let(:list_of_specs) { ['spec/support/sample_spec.rb'] }

  it "runs hooks before run" do
    expect(RSpecConsole).to receive(:hooks).and_call_original
    expect(::RSpec::Core::Runner).to receive(:run).
      with(list_of_specs, STDERR, STDOUT)
    RSpecConsole::Runner.run(list_of_specs)
  end
  it "resets environment while preserving config" do
    expect_any_instance_of(RSpecConsole::ConfigCache).
      to receive(:cache).and_return(nil)
    RSpecConsole::Runner.run(list_of_specs)
  end
end
