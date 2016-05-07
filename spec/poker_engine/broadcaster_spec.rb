require 'rails_helper'

RSpec.describe Broadcaster do

  let!(:room) { FactoryGirl.create(:room) }
  let!(:server) { double('Actioncable.server') }
  let!(:broadcaster) { Broadcaster.new(server, room) }

  before {
    allow(server).to receive(:broadcast)
  }

  describe "notification" do
    it "should broadcast expected message" do
      channel = "room:#{room.id}"
      params = { phase: "play_poker", type: "notification", message: "hoge" }

      expect(server).to receive(:broadcast).with(channel, params)

      broadcaster.notification("hoge")
    end
  end

  describe "ask" do
    let(:player_id) { 1 }

    it "should broadcast expected message" do
      channel = "room:#{room.id}:#{player_id}"
      params = { phase: "play_poker", type: "ask", message: "hoge" }

      expect(server).to receive(:broadcast).with(channel, params)

      broadcaster.ask(player_id, "hoge")
    end
  end

end
