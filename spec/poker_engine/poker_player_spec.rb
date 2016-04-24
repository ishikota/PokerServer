require 'rails_helper'

RSpec.describe PokerPlayer do

  let(:player) { PokerPlayer.new(100) }

  describe "#collect_bet" do

    it "should collect bet from player's stack" do
      player.collect_bet(10)
      expect(player.stack).to eq 90
    end

    it "should raise error when cannot pay specified amount of bet" do
      expect {
        player.collect_bet(200)
      }.to raise_error
    end

  end

  describe "#deactivate" do

    it "should deactivate player" do
      expect { player.deactivate }.to change { player.active? }
    end

  end

end

