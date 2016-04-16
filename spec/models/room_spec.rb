require 'rails_helper'

RSpec.describe Room, :type => :model do

  let(:room) { FactoryGirl.create(:room) }

  describe "validation" do

    describe "on name" do
      it "should reject empty name room" do
        expect { room.name = '' }.to change { room.valid? }.to false
      end
    end

    describe "on max_round" do
      context "when max round is zero" do
        it "should reject" do
          expect { room.max_round = 0 }.to change { room.valid? }.to false
        end
      end
      context "when max round is negative" do
        it "should reject" do
          expect {room.max_round = -1 }.to change { room.valid? }.to false
        end
      end
    end

    describe "on player_num" do
      context "when player number is zero" do
        it "should reject" do
          expect { room.player_num = 0 }.to change { room.valid? }.to false
        end
      end
      context "when player number is negative" do
        it "should reject" do
          expect { room.player_num = -1 }.to change { room.valid? }.to false
        end
      end
    end

  end

  describe "association" do

    describe "with player" do
      let(:player) { FactoryGirl.create(:player) }
      before { EnterRoomRelationship.create(room_id: room.id, player_id: player.id) }

      it "should has_many player" do
        expect(room.players).to include player
      end
    end

  end

  describe "dependency" do

    let(:player) { FactoryGirl.create(:player) }
    before { EnterRoomRelationship.create(room_id: room.id, player_id: player.id) }

    describe "enter room relationship" do
      it "should be destroyed when room is destroyed" do
        expect { room.destroy }.to change { EnterRoomRelationship.count }.to(0)
      end
    end
  end

  describe "logic" do
    describe "available?" do

      context "when room has capacity" do
        it "should be available" do
          expect(room.available?).to be_truthy
        end
      end

      context "when room has no more capacity" do
        let!(:room1) { FactoryGirl.create(:room1) }
        let!(:player1) { FactoryGirl.create(:player1) }
        let!(:player2) { FactoryGirl.create(:player2) }

        before {
          room1.players << player1 << player2
          room1.save
        }

        it "should be unavailable" do
          expect(room1.available?).to be_falsy
        end
      end

    end

  end

end
