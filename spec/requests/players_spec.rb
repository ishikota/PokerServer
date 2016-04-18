require 'rails_helper'
require 'json'

RSpec.describe "players", :type => :request do

  let(:headers) {
    { 'Content-Type': 'application/json', "Accept": "application/json" }
  }

  describe 'POST api/v1/players' do
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

  describe 'GET /api/v1/players/:id' do

    context "when player exists" do
      let!(:player) { FactoryGirl.create(:player) }

      it "should return player info without credential" do
        get "/api/v1/players/#{player.id}", headers: headers
        json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(json["id"]).to eq player.id
        expect(json["name"]).to eq player.name
        expect(json["credential"]).to be_nil
      end
    end

    context "when player does not exist" do
      it "should return 404 not found response" do
        get "/api/v1/players/53", headers: headers
        expect(response.status).to eq 404
      end
    end
  end

  describe "DELETE /player/1" do
    let!(:player) { FactoryGirl.create(:player) }

    it "should success" do
      delete "/api/v1/players/#{player.id}", headers: headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['msg_type']).to eq 'resource_management'
      expect(json['action']).to eq 'destroy_user'
      expect(json['status']).to eq 'success'
      expect(json['message']).to eq "player [ #{player.name} ] is destroyed"
    end
  end
end

