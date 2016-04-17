require 'rails_helper'

RSpec.describe RoomChannelHelper, :type => :helper do

  let!(:player) { FactoryGirl.create(:player) }
  let!(:room) { FactoryGirl.create(:room) }

  describe "generate_arrival_message" do

    context "when have 3 seats and a player is sitting" do
      before { player.take_a_seat(room) }

      it "should include player name and vacant seats count" do
        msg = helper.generate_arrival_message(room, player)
        expect(msg).to match(/2/)
        expect(msg).to match(/#{player.name}/)
      end
    end
  end

  describe "generate_leave_message" do

    it "should include player name and vacant seats count" do
      msg = helper.generate_leave_message(room, player)
      expect(msg).to match(/3/)
      expect(msg).to match(/#{player.name}/)
    end

  end

  describe "generate_game_info" do
    let!(:room1) { FactoryGirl.create(:room1) }
    let!(:player1) { FactoryGirl.create(:player1) }
    let!(:player2) { FactoryGirl.create(:player2) }

    before {
      EnterRoomRelationship.create(room_id: room.id, player_id: player1.id)
      EnterRoomRelationship.create(room_id: room.id, player_id: player2.id)
    }

    it "should contain game rule and players info" do
      msg = helper.generate_game_info(room)
      expect(msg).to match(/#{room1.max_round}/)
      expect(msg).to match(/#{room1.player_num}/)
      expect(msg).to match(/#{player1.name}/)
      expect(msg).to match(/#{player2.name}/)
    end
  end

end
