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

  describe "count method" do

    let(:player2) { double("player2") }

    before {
      seats.sitdown(player)
      seats.sitdown(player2)
      allow(player).to receive(:active?).and_return(true)
    }

    describe "#count_active_player" do

      context "when player 2 is active" do
        before { allow(player2).to receive(:active?).and_return(true) }

        it { expect(seats.count_active_player).to eq 2 }
      end

      context "when player 2 is not active" do
        before { allow(player2).to receive(:active?).and_return(false) }

        it { expect(seats.count_active_player).to eq 1 }
      end

    end

    describe "#count_ask_wait_players" do

      let(:player3) { double("player3") }

      def set_pay_status(target, status)
        allow(target).to receive_message_chain('pay_info.status').and_return status
      end

      before {
        seats.sitdown(player3)
        set_pay_status(player , PokerPlayer::PayInfo::PAY_TILL_END)
        set_pay_status(player2, PokerPlayer::PayInfo::FOLDED)
        set_pay_status(player3, PokerPlayer::PayInfo::ALLIN)
      }

      it "should include only PAY_TILL_END player" do
        expect(seats.count_ask_wait_players).to eq 1
      end
    end

  end

end

