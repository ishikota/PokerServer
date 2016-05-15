require 'rails_helper'

RSpec.describe Broadcaster do

  let!(:room) { double("room") }
  let!(:player) { FactoryGirl.create(:player) }
  let!(:server) { double('Actioncable.server') }
  let!(:broadcaster) { Broadcaster.new(server, room) }

  before {
    allow(server).to receive(:broadcast)
    allow(room).to receive(:id).and_return 1
    allow(room).to receive_message_chain('players.find_by_uuid')
        .with(player.uuid).and_return(player)
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
    let(:channel) { "room:#{room.id}:#{player.id}" }
    let(:params) {
      { phase: "play_poker", type: "ask", counter: 0, message: "hoge" }
    }

    it "should broadcast expected message" do
      expect(server).to receive(:broadcast).with(channel, params)

      broadcaster.ask(player.uuid, "hoge")
    end

    it "should increment ask count" do
      second_params = params.merge( { counter: 1 } )
      expect(server).to receive(:broadcast).with(channel, params)
      expect(server).to receive(:broadcast).with(channel, second_params)
      2.times { broadcaster.ask(player.uuid, "hoge") }
    end
  end

end
