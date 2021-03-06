require 'rails_helper'
require 'poker_engine/round_manager_spec_helper'

RSpec.describe RoomChannelDelegate do
  include RoundManagerSpecHelper

  let(:channel_wrapper) { double("channel wrapper") }
  let(:message_builder) { double("message build helper") }
  let(:dealer_maker) { double("dealer maker") }
  let(:delegate) { RoomChannelDelegate.new(channel_wrapper, message_builder, dealer_maker) }
  let(:welcome_msg) { "welcome msg" }
  let(:arrive_msg) { "arrival msg" }
  let(:start_msg) { "start poker msg" }
  let(:exit_msg) { "exit msg" }
  let(:acc_msg) { "acc msg" }

  let(:room) { FactoryGirl.create(:room1) }
  let(:player) { FactoryGirl.create(:player) }

  before {
    allow(channel_wrapper).to receive(:broadcast)
    allow(channel_wrapper).to receive(:subscribe)

    allow(message_builder).to receive(:build_welcome_message).and_return welcome_msg
    allow(message_builder).to receive(:build_member_arrival_message).and_return arrive_msg
    allow(message_builder).to receive(:build_start_poker_message).and_return start_msg
    allow(message_builder).to receive(:build_member_leave_message).and_return exit_msg
    allow(message_builder).to receive(:build_action_accept_message).and_return acc_msg
  }

  describe "#enter_room" do

    let(:uuid) { "455f420f-940c-4ca2-874b-87ca02d44250" }
    let(:data) do
      { 'room_id' => room.id, 'player_id' => player.id }
    end

    it "should attach uuid to player" do
      expect { delegate.enter_room(uuid, data) }.to change { player.reload.uuid }.to(uuid)
    end

    it "should enter player into room" do
      expect { delegate.enter_room(uuid, data) }.to change { EnterRoomRelationship.count }.by(1)
    end

    it "should subscribe channel" do
      expect(channel_wrapper).to receive(:subscribe).with(room.id)
      expect(channel_wrapper).to receive(:subscribe).with(room.id, player.id)

      delegate.enter_room(uuid, data)
    end

    it "should broadcast arrive message" do
      expect(channel_wrapper).to receive(:broadcast).with(room.id, arrive_msg)
      expect(channel_wrapper).to receive(:broadcast).with(room.id, player.id, welcome_msg)
      expect(channel_wrapper).not_to receive(:broadcast).with(room.id, start_msg)

      delegate.enter_room(uuid, data)
    end

  end

  describe "#exit_room" do
    let(:room_3p) { FactoryGirl.create(:room) }
    let(:someone) { FactoryGirl.create(:player1) }

    before {
      EnterRoomRelationship.create(player_id: player.id, room_id: room_3p.id)
      EnterRoomRelationship.create(player_id: someone.id, room_id: room_3p.id)
    }

    it "should clear room-player relationship" do
      expect { delegate.exit_room(player.uuid) }.to change { EnterRoomRelationship.count }.by(-1)
    end

    it "should clear player uuid" do
      expect { delegate.exit_room(player.uuid) }.to change { player.reload.uuid }.to(nil)
    end

    it "should broadcast exit of player" do
      expect(channel_wrapper).to receive(:broadcast).with(room_3p.id, exit_msg)

      delegate.exit_room(player.uuid)
    end

    context "when room becomes vacant" do

      before {
        state = GameState.create(state: "hoge")
        GameStateRelationship.create(room_id: room_3p.id, game_state_id: state.id)
      }

      it "should clear game state" do
        delegate.exit_room(player.uuid)
        delegate.exit_room(someone.uuid)
        expect(room_3p.reload.game_state).to be_nil
      end
    end

  end

  describe "#connection_check" do
    let(:someone) { FactoryGirl.create(:player1) }
    let(:data) do
      { 'room_id' => room.id, 'player_id' => player.id }
    end

    before {
      EnterRoomRelationship.create(room_id: room.id, player_id: player.id)
    }

    context "when everyone is online but not filled to capaciy" do
      it "should not start the game" do
        expect(channel_wrapper).not_to receive(:broadcast)

        delegate.connection_check(player.uuid)
      end
    end

    context "when everyone is online and fiiled to capacity" do
      let(:dealer) { double("dealer") }
      let(:dealer_message) {
        [] << notification_msg("notify_hoge") << ask_msg(player.uuid, "ask_fuga")
      }

      before {
        allow(dealer).to receive(:serialize).and_return "bar"
        allow(dealer_maker).to receive(:create).and_return(dealer)
        someone.update(online: true)
        EnterRoomRelationship.create(room_id: room.id, player_id: someone.id)
      }

      it "should broadcast start of the game" do
        player_info = [
          { "name" => player.name, "uuid" => player.uuid },
          { "name" => someone.name, "uuid" => someone.uuid }
        ]
        expect(dealer).to receive(:start_game).with(player_info).and_return([])
        expect(channel_wrapper).to receive(:broadcast).with(room.id, start_msg)

        delegate.connection_check(player.uuid)
      end

      it "should broadcast message created by dealer" do
        allow(dealer).to receive(:start_game).and_return(dealer_message)
        expect(channel_wrapper).to receive(:broadcast).with(
          room.id, { phase: "play_poker", type: "notification", message: "notify_hoge"})
        expect(channel_wrapper).to receive(:broadcast).with(
          room.id, player.id, { phase: "play_poker", type: "ask", message: "ask_fuga", counter: 0})

        delegate.connection_check(player.uuid)
        expect(room.game_state.ask_counter).to eq 1
      end

      it "should create new game state" do
        state = "hogehoge"
        allow(dealer).to receive(:serialize).and_return state
        allow(dealer).to receive(:start_game).and_return([])
        delegate.connection_check(player.uuid)

        game_state = room.reload.game_state
        expect(game_state.state).to eq state
        expect(room.game_state.ask_counter).to eq 0
      end
    end
  end

  describe "#declare_action" do

   let(:data) do
     {
       'room_id' => room.id,
       'player_id' => player.id,
       'poker_action' => "fold",
       'bet_amount' => 0
     }
   end

    let(:someone) { FactoryGirl.create(:player1) }
    let(:dealer) { double("dealer") }
    let(:dealer_message) {
      [] << notification_msg("notify_hoge") << ask_msg(player.uuid, "ask_fuga")
    }

    before "create new game state" do
      allow(dealer).to receive(:start_game).and_return([])
      allow(dealer).to receive(:receive_data).and_return(dealer_message)
      allow(dealer).to receive(:serialize).and_return "hogehoge"
      allow(dealer_maker).to receive(:create).and_return(dealer)
      allow(dealer_maker).to receive(:setup_components_holder).and_return "components"
      allow(Dealer).to receive(:deserialize).with("components", "hogehoge").and_return dealer
      delegate.enter_room(player.uuid, data)
      delegate.enter_room(someone.uuid, data.merge( { "player_id" => someone.id } ))
      delegate.connection_check(player.uuid)
      delegate.connection_check(someone.uuid)
    end

    it "should pass action to correct dealer" do
      expect(dealer).to receive(:receive_data).with(player.uuid, data)

      delegate.declare_action(player.uuid, data)
    end

    it "should send accept message to player" do
      expect(channel_wrapper).to receive(:broadcast).with(room.id, player.id, acc_msg)

      delegate.declare_action(player.uuid, data)
    end

    it "should broadcast message created by dealer" do
      allow(dealer).to receive(:start_game).and_return(dealer_message)
      expect(channel_wrapper).to receive(:broadcast).with(room.id, { phase: "play_poker", type: "notification", message: "notify_hoge"} )
      expect(channel_wrapper).to receive(:broadcast).with(room.id, player.id, { phase: "play_poker", type: "ask", message: "ask_fuga", counter: 0})

      delegate.declare_action(player.uuid, data)
      expect(room.game_state.ask_counter).to eq 1
    end

  end

end

