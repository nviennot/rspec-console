require "spec_helper"

describe RSpecConsole::RSpecLastRunState do
  describe "#reset" do
    it "caches rspec config while clearing env details" do
      expect_any_instance_of(RSpecConsole::ConfigCache).
        to receive(:cache)
      RSpecConsole::RSpecLastRunState.reset
    end
    it "raises VersionError if under version 2.9.10" do
      expect(RSpecConsole::RSpecLastRunState).
        to receive(:obsolete_rspec?).and_return(true)
      expect{ RSpecConsole::RSpecLastRunState.reset }.
        to raise_error(RSpecConsole::VersionError, 'Please use RSpec 2.9.10 or later')
    end
  end
end
