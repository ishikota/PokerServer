require 'rails_helper'

RSpec.describe Dealer do

  let(:channel) { setup_mock_channel }
  let(:message_builder) { MessageBuildHelper.new }
  let(:dealer_maker) { DealerMaker.new }
  let(:delegate) { RoomChannelDelegate.new(channel, message_builder, dealer_maker) }

  let(:room) { FactoryGirl.create(:room1) }
  let(:player1) { FactoryGirl.create(:player1) }
  let(:player2) { FactoryGirl.create(:player2) }

  describe "start the game" do

    before {
      delegate.enter_room(player1.uuid, setup_data(room, player1))
      delegate.enter_room(player2.uuid, setup_data(room, player2))
    }

    it "should save preflop dealer state" do
      state = JSON.parse(room.game_state.state)
      table = Marshal.load(state["table"])
      expect(table.seats.players.first.hole_card.size).to eq 2
      expect(table.community_card.cards).to be_empty
    end
  end

  describe "update the game" do
    let(:action_data) { { "action" => "call", "bet_amount" => 10 } }
    let(:data) { setup_data(room, player1).merge!(action_data) }

    before {
      delegate.enter_room(player1.uuid, setup_data(room, player1))
      delegate.enter_room(player2.uuid, setup_data(room, player2))
    }

    it "should save updated game state" do
      delegate.declare_action(player1.uuid, data)
      state = JSON.parse(room.game_state.state)
      table = Marshal.load(state["table"])
      expect(table.community_card.cards.size).to eq 3
    end
  end

  private

    def setup_data(room, player)
      { "room_id" => room.id, "player_id" => player.id }
    end

    def setup_mock_channel
      double("channel").tap { |channel|
        allow(channel).to receive(:subscribe)
        allow(channel).to receive(:broadcast)
      }
    end

end
