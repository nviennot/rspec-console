require "spec_helper"

describe RSpecConsole::Environment do
  describe "#reset" do
    it "caches rspec config while clearing env details" do
      expect_any_instance_of(RSpecConsole::ConfigCache).
        to receive(:cache)
      RSpecConsole::Environment.reset
    end
    it "raises VersionError if under version 2.9.10" do
      expect(RSpecConsole::Environment).
        to receive(:obsolete_rspec?).and_return(true)
      expect{ RSpecConsole::Environment.reset }.
        to raise_error(RSpecConsole::VersionError)
    end
  end
end
