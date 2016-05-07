require 'rails_helper'

RSpec.describe RoomChannelDelegate do

  let(:channel_wrapper) { double("channel wrapper") }
  let(:message_builder) { double("message build helper") }
  let(:delegate) { RoomChannelDelegate.new(channel_wrapper, message_builder) }
  let(:welcome_msg) { "welcome msg" }
  let(:arrive_msg) { "arrival msg" }
  let(:start_msg) { "start poker msg" }

  before {
    allow(message_builder).to receive(:build_welcome_message).and_return welcome_msg
    allow(message_builder).to receive(:build_member_arrival_message).and_return arrive_msg
  }

  describe "#enter_room" do
    let(:room) { FactoryGirl.create(:room1) }
    let(:player) { FactoryGirl.create(:player) }

    let(:data) do
      { 'room_id' => room.id, 'player_id' => player.id }
    end

    before {
      allow(channel_wrapper).to receive(:broadcast)
      allow(channel_wrapper).to receive(:subscribe)
    }

    it "should enter player into room" do
      expect { delegate.enter_room(data) }.to change { EnterRoomRelationship.count }.by(1)
    end

    it "should subscribe channel" do
      expect(channel_wrapper).to receive(:subscribe).with(room.id)
      expect(channel_wrapper).to receive(:subscribe).with(room.id, player.id)

      delegate.enter_room(data)
    end

    it "should broadcast arrive message" do
      expect(channel_wrapper).to receive(:broadcast).with(room.id, arrive_msg)
      expect(channel_wrapper).to receive(:broadcast).with(room.id, player.id, welcome_msg)
      expect(channel_wrapper).not_to receive(:broadcast).with(room.id, start_msg)

      delegate.enter_room(data)
    end

    context "when all member is gatherd" do
      let(:someone) { FactoryGirl.create(:player1) }

      before {
        EnterRoomRelationship.create(player_id: someone.id, room_id: room.id)
      }

      it "should broadcast start of the game" do
        expect(channel_wrapper).to receive(:broadcast).with(room.id, start_msg)

        delegate.enter_room(data)
      end

      it "should create dealer and start the game"

    end

  end

end

