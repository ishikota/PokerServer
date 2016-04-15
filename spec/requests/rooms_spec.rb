require 'rails_helper'
require 'json'

RSpec.describe "rooms", :type => :request do

  let(:headers) {
    { 'Content-Type': 'application/json', "Accept": "application/json" }
  }

  describe 'POST api/v1/rooms' do
    let(:params) {
      { room: FactoryGirl.attributes_for(:room) }.to_json
    }

    it "should success" do
      post '/api/v1/rooms', params, headers
      json = JSON.parse(response.body)
      p = JSON.parse(params)
      expect(response.status).to eq 200
      expect(json["id"]).to eq 1
      expect(json["name"]).to eq p["room"]["name"]
      expect(json["max_round"]).to eq p["room"]["max_round"]
      expect(json["player_num"]).to eq p["room"]["player_num"]
    end
  end

  describe 'GET /api/v1/rooms' do

    describe "with status parameter" do
      let!(:player1) { FactoryGirl.create(:player1) }
      let!(:player2) { FactoryGirl.create(:player2) }
      let!(:room1) { FactoryGirl.create(:room1) }
      let!(:room2) { FactoryGirl.create(:room2) }

      before "fill room1 capacity" do
        room1.players << player1 << player2
        room1.save
      end

      context "when status is not specified" do
        it "should return all registered room" do
          get '/api/v1/rooms', headers: headers
          json = JSON.parse(response.body)
          expect(response.status).to eq 200
          expect(json.size).to eq 2
        end
      end

      context "when status is available" do
        let(:params) {
          { status: "available" }
        }

        it "should return only rooms which does not reach its capacity" do
          get '/api/v1/rooms', params: params, headers: headers
          json = JSON.parse(response.body).map { |j| JSON.parse(j) }
          expect(response.status).to eq 200
          expect(json.size).to eq 1
          expect(json[0]["name"]).to eq room2.name
        end
      end

    end
  end

  describe 'DELETE api/v1/rooms/:id' do
    let!(:room) { FactoryGirl.create(:room) }
    it "should success" do
      delete "/api/v1/rooms/#{room.id}", headers: headers
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['msg_type']).to eq 'resource_management'
      expect(json['action']).to eq 'destroy_room'
      expect(json['status']).to eq 'success'
      expect(json['message']).to eq "room [ #{room.name} ] is destroyed"
    end
  end

end

