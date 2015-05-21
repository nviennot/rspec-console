require "spec_helper"

describe RSpecConsole::Environment do
  describe "#reset" do
    it "caches rspec config while clearing env details" do
      expect_any_instance_of(RSpecConsole::ConfigCache).
        to receive(:cache)
      RSpecConsole::Environment.reset
    end
  end
end
