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
    let(:cmd) { double }
    it "relies on create_command in Pry" do
      expect(cmd).to receive(:create_command).with("rspec",
        "Runs specs; to silence ActiveRecord output use SILENCE_AR=true")
      RSpecConsole::Pry.rspec_command(cmd)
    end
  end
end
