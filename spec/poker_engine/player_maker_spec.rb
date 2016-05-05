require 'rails_helper'

RSpec.describe PlayerMaker do
  let(:maker) { PlayerMaker.new }

  describe "create" do
    let(:player_info) do
      { "name" => "hoge" }
    end

    it "should create player by using passed name and initial stack" do
      player = maker.create(player_info, 50)
      expect(player.name).to eq "hoge"
      expect(player.stack).to eq 50
    end
  end

end

