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

  describe 'DELETE api/v1/rooms/:id' do
    it "should success"
  end

end

