require "spec_helper"
require "pry"

describe RSpecConsole::Pry do
  describe ".setup" do
    it "relies on Pry::Commands" do
      expect(::Pry::CommandSet).to receive(:new)
      expect(::Pry::Commands).to receive(:import)
      RSpecConsole::Pry.setup
    end
    it "adds pry command" do
      RSpecConsole::Pry.setup
      expect(Pry::Commands.valid_command?("rspec")).to eq(true)
    end
  end
  describe ".rspec_command" do
    let(:proc) { RSpecConsole::Pry.send(:rspec_command) }
    it "is a proc" do
      expect(proc).to be_a(Proc)
    end
    it "relies on create_command in Pry" do
      expect_any_instance_of(::Pry::CommandSet).
        to receive(:create_command).
      with(
        "rspec",
        "Runs specs; to silence ActiveRecord output use SILENCE_AR=true"
      )
      ::Pry::CommandSet.new(&proc)
    end
  end
end
