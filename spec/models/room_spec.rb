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

end
