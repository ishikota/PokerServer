require 'rails_helper'

RSpec.describe DataBridge do

  let!(:broadcaster) { double("broadcaster") }
  let!(:dealer) { double("dealer") }
  let!(:data_bridge) { DataBridge.new(dealer, broadcaster) }
  let!(:ask_data) { { player_id: 1, data: "hoge" } }

  describe "#run" do
    before {
      allow(dealer).to receive(:setup)
      allow(dealer).to receive(:run_until_ask_action).and_return(ask_data)
      allow(broadcaster).to receive(:ask)
    }

    it "should run dealer" do
      expect(dealer).to receive(:setup)
      expect(dealer).to receive(:run_until_ask_action).with("TODO START MESSAGE")

      data_bridge.run()
    end
  end

  describe "#receive_data" do

    before {
      allow(dealer).to receive(:run_until_ask_action).and_return(ask_data)
    }

    it "should pass data to dealer" do
      expect(dealer).to receive(:run_until_ask_action).with("fuga")
      expect(broadcaster).to receive(:ask).with(1, "hoge")

      data_bridge.receive_data("fuga")
    end
  end

end

