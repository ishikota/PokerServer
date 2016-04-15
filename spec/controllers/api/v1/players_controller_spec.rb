require 'rails_helper'

RSpec.describe Api::V1::PlayersController, :type => :controller do

  describe '#create' do
    let(:params) { { player: { name: "kota" } } }

    describe "with correct params" do
      it "should create new player" do
        post :create, params
        player = Player.find_by_name("kota")
        expect(player).to be_present
      end
    end
  end

  describe "#destroy" do
    let(:player) { FactoryGirl.create(:player) }

    it "shuold destroy player" do
      delete :destroy, id: player
      expect(Player.count).to eq 0
    end
  end

end
