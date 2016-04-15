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

end
