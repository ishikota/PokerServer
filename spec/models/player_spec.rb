require 'rails_helper'

RSpec.describe Player, :type => :model do

  let(:player) { FactoryGirl.create(:player) }

  describe "validation" do

    describe "on name" do
      it "should reject empty name player" do
        expect { player.name = "" }.to change { player.valid? }.from(true).to(false)
      end
    end

    describe "on credential" do
      it "should reject wrong length credential" do
        expect { player.credential = 'a' * 21 }.to change { player.valid? }.to false
        expect { player.credential = 'a' * 22 }.to change { player.valid? }.to true
        expect { player.credential = 'a' * 23 }.to change { player.valid? }.to false
      end
    end

    describe "on online" do
      it "should reject null connection state" do
        expect { player.online = nil }.to change { player.valid? }.to false
      end
    end
  end

  describe "association" do

    describe "with room" do
      let!(:room) { FactoryGirl.create(:room) }
      before { EnterRoomRelationship.create(room_id: room.id, player_id: player.id) }

      it "should belong" do
        expect(player.room).to eq room
        expect(player.current_room).to eq room
      end
    end

  end

  describe "take_a_seat" do
    let!(:room) { FactoryGirl.create(:room) }

    context "when not entering room" do
      let!(:someone) { FactoryGirl.create(:player1) }
      before { EnterRoomRelationship.create(room_id: room.id, player_id: someone.id) }

      it "should create EnterRoomRelationship" do
        expect { player.take_a_seat(room) }.to change { EnterRoomRelationship.count }
      end
    end

    context "when already in the room" do
      before { EnterRoomRelationship.create(room_id: room.id, player_id: player.id) }

      it "should not create new relation" do
        expect { player.take_a_seat(room) }.not_to change { EnterRoomRelationship.count }
      end

    end

    # TODO refactor
    describe "update latest relation" do
      let!(:someone) { FactoryGirl.create(:player1) }
      let!(:old_relation) { EnterRoomRelationship.create(room_id: room.id, player_id: player.id, updated_at: 1.day.ago) }
      let!(:new_relation) { EnterRoomRelationship.create(room_id: room.id, player_id: someone.id, updated_at: 1.hour.ago) }

      it "should make relation latest in the room" do
        expect(old_relation.updated_at).to be < new_relation.updated_at
        player.take_a_seat(room)
        expect(old_relation.reload.updated_at).to be > new_relation.updated_at
      end
    end

  end

  describe "clear_state" do
    let!(:room) { FactoryGirl.create(:room) }
    let(:uuid) { "455f420f-940c-4ca2-874b-87ca02d44250" }

    before {
      player.update_attributes(uuid: uuid)
      player.update_attributes(online: true)
      EnterRoomRelationship.create(room_id: room.id, player_id: player.id)
    }

    it "should clear room-in state" do
      expect { player.clear_state }.to change { EnterRoomRelationship.count }.by(-1)
    end

    it "should clear uuid" do
      expect { player.clear_state }.to change { player.reload.uuid }.to(nil)
    end

    it "should clear connection state" do
      expect { player.clear_state }.to change { player.reload.online? }.to(false)
    end
  end

end
