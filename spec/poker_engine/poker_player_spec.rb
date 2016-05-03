require 'rails_helper'

RSpec.describe PokerPlayer do

  let(:player) { PokerPlayer.new(100) }

  describe "add_holecard" do

    describe "pass wrong number of card" do

      it "should raise error" do
        expect { player.add_holecard([create_mock_card(2,2)]) }.to raise_error
        expect { player.add_holecard(create_mock_card(2,2)) }.to raise_error
        expect { player.add_holecard(
          [create_mock_card(2,2), create_mock_card(2,2), create_mock_card(2,2)])
        }.to raise_error
      end

    end

    context "when already has hole card" do
      before {
        player.add_holecard([create_mock_card(2,2), create_mock_card(4,4)])
      }

      it "should raise error" do
        expect { player.add_holecard(
          [create_mock_card(2,2), create_mock_card(2,2)])
        }.to raise_error
      end
    end


    it "should success"  do
      cards = [create_mock_card(2,2), create_mock_card(4,4)]
      player.add_holecard(cards)
      expect(player.hole_card).to include cards[0]
      expect(player.hole_card).to include cards[1]
    end

  end

  describe "#append_chip" do
    it "should append chip to player's stack" do
      expect { player.append_chip(10) }.to change { player.stack }.by(10)
    end
  end

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

  describe "add_action_history" do

    context "FOLD" do

      before {
        player.add_action_history(PokerPlayer::ACTION::FOLD)
      }

      it "should add action_history" do
        expect(player.action_histories.last["action"]).to eq "FOLD"
      end
    end

    describe "CALL" do

      context "when player has enought money to action" do

        before {
          player.add_action_history(PokerPlayer::ACTION::CALL, 10)
        }

        it "should add action_history" do
          expect(player.action_histories.last["action"]).to eq "CALL"
          expect(player.action_histories.last["amount"]).to eq 10
          expect(player.action_histories.last["paid"]).to eq 10
        end

        context "call $20 when already paid $10" do

          before {
            player.add_action_history(PokerPlayer::ACTION::CALL, 20)
          }

          it "should pay only $10" do
            expect(player.action_histories.last["amount"]).to eq 20
            expect(player.action_histories.last["paid"]).to eq 10
          end

        end
      end

    end

    describe "RAISE" do

      before {
        player.add_action_history(PokerPlayer::ACTION::RAISE, 10)
      }

      it "should add action_history" do
        expect(player.action_histories.last["action"]).to eq "RAISE"
        expect(player.action_histories.last["amount"]).to eq 10
        expect(player.action_histories.last["paid"]).to eq 10
      end

      context "call $20 when already paid $10" do

        before {
          player.add_action_history(PokerPlayer::ACTION::CALL, 20)
        }

        it "should pay only $10" do
          expect(player.action_histories.last["amount"]).to eq 20
          expect(player.action_histories.last["paid"]).to eq 10
        end
      end

    end

  end

  private

    def create_mock_card(rank, suit)
      card = double("Card rank:#{rank}, suit#{suit}")
      allow(card).to receive(:is_a?).with(Card).and_return true
      card
    end

end

