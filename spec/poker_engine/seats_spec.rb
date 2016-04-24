require 'rails_helper'

RSpec.describe Seats do

  let(:seats) { Seats.new }

  describe "#sit_down" do
    let(:player) { double("player") }

    it "should set player" do
      seats.sitdown(player)
      expect(seats.players).to include(player)
    end

  end

  describe "#size" do

    it "should return the number of players who sit on"

  end

  describe "#collect_bet" do

    it "should collect bet from second player"

  end

  describe "#deactivate" do

    it "should deactivate specified player"

  end

end

