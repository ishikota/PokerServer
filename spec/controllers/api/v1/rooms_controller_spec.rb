require 'rails_helper'

RSpec.describe Api::V1::RoomsController, :type => :controller do

  describe '#create' do
    let(:params) {
      { room: FactoryGirl.attributes_for(:room) }
    }
    it "should create new room" do
      post :create, params
      room = Room.find_by_name(params[:room][:name])
      expect(room.max_round).to eq params[:room][:max_round]
      expect(room.player_num).to eq params[:room][:player_num]
    end
  end

  describe '#destroy' do

    let!(:room) { FactoryGirl.create(:room) }

    it "should destroy the room" do
      delete :destroy, id: room
      expect(Room.count).to eq 0
    end
  end

end
