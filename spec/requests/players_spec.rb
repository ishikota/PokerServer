require 'rails_helper'
require 'json'

RSpec.describe "players", :type => :request do

  let(:headers) {
    { 'Content-Type': 'application/json', "Accept": "application/json" }
  }

  describe 'GET api/v1/players' do
    let(:params) { '{ "player" : { "name" : "kota" } }' }

    it "should success" do
      post '/api/v1/players', params: params, headers: headers
      json = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(json['name']).to eq 'kota'
      expect(json['id']).to eq 1
      expect(json['credential']).to be_nil
      expect(json['created_at']).to be_nil
      expect(json['updated_at']).to be_nil
    end
  end

  describe "DELETE /player/1" do
    let!(:player) { FactoryGirl.create(:player) }

    it "should success" do
      delete "/api/v1/players/#{player.id}", headers: headers
      expect(response.status).to eq 200
    end
  end
end

