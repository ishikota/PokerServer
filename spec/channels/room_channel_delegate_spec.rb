require 'rails_helper'
require "#{Rails.root}/app/helpers/message_build_helper"

RSpec.describe RoomChannelDelegate do
  include MessageBuildHelper

  let(:channel_wrapper) { double("channel wrapper") }
  let(:delegate) { RoomChannelDelegate.new(channel_wrapper) }

  describe "#enter_room" do
    let(:room) { FactoryGirl.create(:room1) }
    let(:player) { FactoryGirl.create(:player) }
    let(:arrive_msg) { build_member_arrival_message(room, player) }
    let(:welcome_msg) { build_welcome_message }
    let(:start_msg) { "start poker msg" }

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

