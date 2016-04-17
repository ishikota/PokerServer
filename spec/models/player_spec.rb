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
  end

  describe "association" do

    describe "with room" do
      let!(:room) { FactoryGirl.create(:room) }
      before { EnterRoomRelationship.create(room_id: room.id, player_id: player.id) }

      it "should belong" do
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

      it "should do nothing" do
        expect { player.take_a_seat(room) }.not_to change { EnterRoomRelationship.count }
      end
    end

  end

end
