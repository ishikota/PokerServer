require 'rails_helper'

RSpec.describe RoomChannelDelegate do

  let(:channel_wrapper) { double("channel wrapper") }
  let(:message_builder) { double("message build helper") }
  let(:delegate) { RoomChannelDelegate.new(channel_wrapper, message_builder) }
  let(:welcome_msg) { "welcome msg" }
  let(:arrive_msg) { "arrival msg" }
  let(:start_msg) { "start poker msg" }
  let(:exit_msg) { "exit msg" }

  let(:room) { FactoryGirl.create(:room1) }
  let(:player) { FactoryGirl.create(:player) }
  let(:uuid) { "455f420f-940c-4ca2-874b-87ca02d44250" }

  before {
    allow(channel_wrapper).to receive(:broadcast)
    allow(channel_wrapper).to receive(:subscribe)

    allow(message_builder).to receive(:build_welcome_message).and_return welcome_msg
    allow(message_builder).to receive(:build_member_arrival_message).and_return arrive_msg
    allow(message_builder).to receive(:build_start_poker_message).and_return start_msg
    allow(message_builder).to receive(:build_member_leave_message).and_return exit_msg
  }

  describe "#enter_room" do

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

      before {
        allow_any_instance_of(Dealer).to receive(:start_game)
        EnterRoomRelationship.create(player_id: someone.id, room_id: room.id)
      }

      it "should broadcast start of the game" do
        expect(channel_wrapper).to receive(:broadcast).with(room.id, start_msg)

        delegate.enter_room(uuid, data)
      end

      it "should create dealer and start the game"

    end

  end

  describe "#exit_room" do

    before {
      EnterRoomRelationship.create(player_id: player.id, room_id: room.id)
      player.update_attributes(uuid: uuid)
    }

    it "should clear room-player relationship" do
      expect { delegate.exit_room(uuid) }.to change { EnterRoomRelationship.count }.by(-1)
    end

    it "should clear player uuid" do
      expect { delegate.exit_room(uuid) }.to change { player.reload.uuid }.to(nil)
    end

    it "should broadcast exit of player" do
      expect(channel_wrapper).to receive(:broadcast).with(room.id, exit_msg)

      delegate.exit_room(uuid)
    end

  end


end

