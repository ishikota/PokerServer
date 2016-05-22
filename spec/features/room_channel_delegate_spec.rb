require 'rails_helper'

RSpec.describe Dealer do

  let(:channel) { setup_mock_channel }
  let(:message_builder) { MessageBuildHelper.new }
  let(:dealer_maker) { DealerMaker.new }
  let(:delegate) { RoomChannelDelegate.new(channel, message_builder, dealer_maker) }

  let(:room) { FactoryGirl.create(:room1) }
  let(:player1) { FactoryGirl.create(:player1) }
  let(:player2) { FactoryGirl.create(:player2) }

  before {
    delegate.enter_room(player1.uuid, setup_data(room, player1))
    delegate.enter_room(player2.uuid, setup_data(room, player2))
    delegate.connection_check(player1.uuid)
    delegate.connection_check(player2.uuid)
  }

  describe "start the game" do

    it "should save preflop dealer state" do
      state = JSON.parse(room.game_state.state)
      table = Marshal.load(state["table"])
      expect(table.seats.players.first.hole_card.size).to eq 2
      expect(table.community_card.cards).to be_empty
    end
  end

  describe "update the game" do
    let(:action_data) { { "poker_action" => "call", "bet_amount" => 10 } }
    let(:data) { setup_data(room, player1).merge!(action_data) }

    it "should save updated game state" do
      delegate.declare_action(player1.uuid, data)
      state = JSON.parse(room.game_state.state)
      table = Marshal.load(state["table"])
      expect(table.community_card.cards.size).to eq 3
    end
  end

  describe "street start message" do
    let(:action_data) { { "poker_action" => "call", "bet_amount" => 10 } }
    let(:data) { setup_data(room, player1).merge!(action_data) }

    let(:poker_msg) do
      {
        phase: "play_poker",
        type: "notification",
        message: flop_msg
      }
    end

    let(:flop_msg) do
      {
        "message_type"=>"street_start_message",
        "round_state"=> {
          "street"=>"FLOP",
          "community_card"=>[anything, anything, anything],
          "dealer_btn" => anything,
          "seats" => anything,
          "pot" => anything,
          "next_player"=> anything
        },
        "street"=>"FLOP"
      }
    end


    it "should be sent after street setup is done" do
      expect(channel).to receive(:broadcast).with(room.id, poker_msg)
      delegate.declare_action(player1.uuid, data)
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
