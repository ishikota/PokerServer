require 'rails_helper'

RSpec.describe RoomChannelDelegate do

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

    context "when all member is gatherd" do
      let(:someone) { FactoryGirl.create(:player1) }
      let(:dealer) { double("dealer") }

      before {
        allow(dealer_maker).to receive(:create).and_return(dealer)
        EnterRoomRelationship.create(player_id: someone.id, room_id: room.id)
      }

      it "should broadcast start of the game" do
        pending "player order is reversed compared to what we expected"
        player_info = [ { "name" => player.name, "uuid" => uuid }, { "name" => someone.name, "uuid" => someone.uuid } ]
        expect(dealer).to receive(:start_game).with(player_info)
        expect(channel_wrapper).to receive(:broadcast).with(room.id, start_msg)

        delegate.enter_room(uuid, data)
      end

    end

  end

  describe "#exit_room" do

    before {
      EnterRoomRelationship.create(player_id: player.id, room_id: room.id)
    }

    it "should clear room-player relationship" do
      expect { delegate.exit_room(player.uuid) }.to change { EnterRoomRelationship.count }.by(-1)
    end

    it "should clear player uuid" do
      expect { delegate.exit_room(player.uuid) }.to change { player.reload.uuid }.to(nil)
    end

    it "should broadcast exit of player" do
      expect(channel_wrapper).to receive(:broadcast).with(room.id, exit_msg)

      delegate.exit_room(player.uuid)
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

    before "put dealer in dealer_hash" do
      allow(dealer).to receive(:start_game)
      allow(dealer).to receive(:receive_data)
      allow(dealer_maker).to receive(:create).and_return(dealer)
      delegate.enter_room(player.uuid, data)
      delegate.enter_room(someone.uuid, data.merge( { "player_id" => someone.id } ))
    end

    it "should pass action to correct dealer" do
      expect(dealer).to receive(:receive_data).with(player.uuid, data)

      delegate.declare_action(player.uuid, data)
    end

    it "should send accept message to player" do
      expect(channel_wrapper).to receive(:broadcast).with(room.id, player.id, acc_msg)

      delegate.declare_action(player.uuid, data)
    end

  end


end

