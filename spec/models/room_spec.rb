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

    describe "with game state" do
      let(:game_state) { FactoryGirl.create(:game_state) }
      before { GameStateRelationship.create(room_id: room.id, game_state_id: game_state.id) }

      it "should have a game state" do
        expect(room.game_state).to eq game_state
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
    describe "filled_to_capacity?" do

      context "when room has capacity" do
        it "should return false" do
          expect(room.filled_to_capacity?).to be_falsy
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

        it "should return true" do
          expect(room1.filled_to_capacity?).to be_truthy
        end
      end

    end

    describe "everyone_online?" do
      let(:room) { FactoryGirl.create(:room1) }
      let!(:player1) { FactoryGirl.create(:player1) }
      let!(:player2) { FactoryGirl.create(:player2) }

      before {
        room.players << player1 << player2
        room.save
      }

      context "when offline player exists" do
        it "should return false" do
          expect(room.everyone_online?).to be_falsy
        end
      end

      context "when everyone is online" do

        before {
          player1.update(online: true)
          player2.update(online: true)
        }

        it "should return true" do
          expect(room.everyone_online?).to be_truthy
        end
      end
    end

    describe "clear_state" do

      before {
        state1 = GameState.create(state: "hoge")
        state2 = GameState.create(state: "huga")
        GameStateRelationship.create(room_id: room.id, game_state_id: state1.id)
        GameStateRelationship.create(room_id: room.id, game_state_id: state2.id)
      }

      it "should clear game state" do
        room.clear_state
        expect(room.reload.game_state).to be_nil
        expect(room.reload.game_state_relationship).to be_nil
      end
    end

  end

end
