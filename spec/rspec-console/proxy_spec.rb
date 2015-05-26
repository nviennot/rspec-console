require "spec_helper"

describe RSpecConsole::Proxy do
  let(:proxy) { RSpecConsole::Proxy.new(RSpec.configuration) }
  it "records the original config" do
    proxy.ordering_manager
    expect(proxy.persisted_config).to eq(
      [
        {
          method: :ordering_manager,
          args: [],
          block: nil
        }
      ]
    )
  end
end
