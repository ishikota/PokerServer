require 'rails_helper'

RSpec.describe EnterRoomRelationship, :type => :model do

  let!(:player) { FactoryGirl.create(:player) }
  let!(:room) { FactoryGirl.create(:room) }
  let!(:relation) { EnterRoomRelationship.new(player_id: player.id, room_id: room.id) }

  describe "validation" do
    #it { is_expected.to validate_presence_of :player_id }
    #it { is_expected.to validate_presence_of :room_id }

    describe "on uniqueness" do

     before { relation.save }

     it "should reject that plyaer enters room duplicatedly" do
       expect {
         EnterRoomRelationship.create(player_id: player.id, room_id: room.id)
       }.not_to change {
         EnterRoomRelationship.count
       }
     end
    end
  end

end
