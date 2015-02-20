require "spec_helper"

describe RSpecConsole::ConfigCache do
  let(:cache) do
    described_class.new
  end

  describe "#cache" do
    it "defines method_missing method on RSpec.configuration's singleton class" do
      cache.cache {}
      expect(RSpec.configuration.respond_to?(:method_missing)).to be_true
    end
  end
end
