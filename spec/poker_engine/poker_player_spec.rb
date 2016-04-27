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

  describe "pay_info" do

    before {
      player.init_pay_info
    }

    describe "#update" do

      context "by pay more chip" do

        it "should append pay amount" do
          expect {
            player.pay_info.update_by_pay(10)
          }.to change { player.pay_info.amount }.by(10)
          expect(player.pay_info.status).to eq (PokerPlayer::PayInfo::PAY_TILL_END)
        end
      end

      context "by fold" do

        it "should update state to fold" do
          expect {
            player.pay_info.update_to_fold
          }.to change { player.pay_info.status }.to PokerPlayer::PayInfo::FOLDED
        end
      end

      context "by all-in" do

        it "should append pay amount and update state to ALLIN" do
          expect {
            player.pay_info.update_to_allin(10)
          }.to change { player.pay_info.amount }.by(10)
          .and change { player.pay_info.status }.to PokerPlayer::PayInfo::ALLIN
        end
      end

    end
  end

end

