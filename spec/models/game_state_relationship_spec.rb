require 'rails_helper'

RSpec.describe GameStateRelationship, :type => :model do

  let!(:room) { FactoryGirl.create(:room) }
  let!(:game_state) { FactoryGirl.create(:game_state) }
  let(:relation) { GameStateRelationship.new(room_id: room.id, game_state_id: game_state.id) }

  describe "validation" do

    it "should reject empty room_id relationship" do
      expect { relation.room_id = nil }.to change { relation.valid? }.to false
    end

    it "should reject empty game_state_id relationship" do
      expect { relation.game_state_id = nil }.to change { relation.valid? }.to false
    end
  end

end

