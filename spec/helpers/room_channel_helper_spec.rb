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

end
