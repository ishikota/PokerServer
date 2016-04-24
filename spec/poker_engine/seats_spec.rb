require 'rails_helper'

RSpec.describe Seats do

  let(:seats) { Seats.new }
  let(:player) { double("player") }

  describe "#sit_down" do

    it "should set player" do
      seats.sitdown(player)
      expect(seats.players).to include(player)
    end

  end

  describe "#size" do

    before {
      seats.sitdown(player)
    }

    it "should return the number of players who sit on" do
      expect(seats.size).to eq 1
    end

  end

  describe "#collect_bet" do

    let(:player2) { double("player2") }
    before {
      seats.sitdown(player)
      seats.sitdown(player2)
    }

    it "should collect bet from second player" do
      expect(player2).to receive(:collect_bet).with(2)
      seats.collect_bet(1, 2)
    end

  end

  describe "#deactivate" do

    let(:player2) { double("player2") }
    before {
      seats.sitdown(player)
      seats.sitdown(player2)
    }

    it "should deactivate specified player" do
      expect(player2).to receive(:deactivate)
      seats.deactivate(1)
    end
  end

end

