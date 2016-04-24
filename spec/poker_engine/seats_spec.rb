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

    it "should collect bet from second player"

  end

  describe "#deactivate" do

    it "should deactivate specified player"

  end

end

