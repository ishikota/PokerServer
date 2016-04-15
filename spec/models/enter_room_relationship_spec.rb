require 'rails_helper'

RSpec.describe EnterRoomRelationship, :type => :model do

  let!(:player) { FactoryGirl.create(:player) }
  let!(:room) { FactoryGirl.create(:room) }
  let!(:relation) { EnterRoomRelationship.new(player_id: player.id, room_id: room.id) }

  describe "validation" do
    #it { is_expected.to validate_presence_of :player_id }
    #it { is_expected.to validate_presence_of :room_id }
  end

end
