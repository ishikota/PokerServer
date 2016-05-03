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

  end

  describe "#count_active_player" do
    let(:player2) { double("player2") }

    before {
      seats.sitdown(player)
      seats.sitdown(player2)
      allow(player).to receive(:active?).and_return(true)
    }

    context "when player 2 is active" do
      before { allow(player2).to receive(:active?).and_return(true) }

      it { expect(seats.count_active_player).to eq 2 }
    end

    context "when player 2 is not active" do
      before { allow(player2).to receive(:active?).and_return(false) }

      it { expect(seats.count_active_player).to eq 1 }
    end

  end

end

