require 'rails_helper'

RSpec.describe PlayerMaker do
  let(:maker) { PlayerMaker.new }

  describe "create" do
    let(:player_info) do
      { "name" => "hoge", "uuid" => "3165ec01-152a-4803-b685-e7f0be8f7bc6" }
    end

    it "should create player by using passed name and initial stack" do
      player = maker.create(player_info, 50)
      expect(player.stack).to eq 50
      expect(player.name).to eq player_info["name"]
      expect(player.uuid).to eq player_info["uuid"]
    end
  end

end

