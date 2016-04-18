require 'rails_helper'

RSpec.describe ServerInterface do

  let!(:room) { FactoryGirl.create(:room) }
  let!(:server) { double('Actioncable.server') }
  let!(:server_interface) { ServerInterface.new(server, room) }

  before {
    allow(server).to receive(:broadcast)
  }

  describe "notification" do
    it "should broadcast expected message" do
      channel = "room:#{room.id}"
      params = { phase: "play_poker", type: "notification", message: "hoge" }

      expect(server).to receive(:broadcast).with(channel, params)

      server_interface.notification("hoge")
    end
  end

  describe "ask" do
    let(:player_id) { 1 }

    it "should broadcast expected message" do
      channel = "room:#{room.id}:#{player_id}"
      params = { phase: "play_poker", type: "ask", message: "hoge" }

      expect(server).to receive(:broadcast).with(channel, params)

      server_interface.ask(player_id, "hoge")
    end
  end

end
