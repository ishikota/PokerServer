require 'rails_helper'
require 'features/feature_spec_helper'

RSpec.describe RoundManager do
  include FeatureSpecHelper

  let(:finish_callback) { double("finish_callback") }
  let(:broadcaster) { double("broadcaster") }
  let(:hand_evaluator) { HandEvaluator.new }
  let(:game_evaluator) { GameEvaluator.new(hand_evaluator) }
  let(:message_builder) { double("message_builder") }
  let(:round_manager) { RoundManager.new(broadcaster, game_evaluator, message_builder) }
  let(:action_checker) { ActionChecker.new }

  let(:round_start_msg) { "round starts" }
  let(:street_start_msg) { "street starts" }
  let(:ask_msg) { "ask" }
  let(:update_msg) { "update" }

  before {
    round_manager.set_finish_callback(finish_callback)

    allow(broadcaster).to receive(:notification)
    allow(broadcaster).to receive(:ask)
    allow(message_builder).to receive(:round_start_message).and_return(round_start_msg)
    allow(message_builder).to receive(:street_start_message).and_return(street_start_msg)
    allow(message_builder).to receive(:ask_message).and_return(ask_msg)
    allow(message_builder).to receive(:game_update_message).and_return(update_msg)
  }

  describe "player a round with two player" do
    let(:table) { Table.new(cheat_deck) }
    let(:player1) { PokerPlayer.new(name="p1", 100) }
    let(:player2) { PokerPlayer.new(name="p2", 100) }

    before {
      table.seats.sitdown(player1)
      table.seats.sitdown(player2)
    }

    it "should notify starts of the round to all players" do
      expect(broadcaster).to receive(:notification).with("round starts")
      expect(broadcaster).to receive(:notification).with("street starts")

      round_manager.start_new_round(table)
    end

    it "should collect blind" do
      expect {
        round_manager.start_new_round(table)
      }.to change { player1.stack }.by(-5)
       .and change { player2.stack }.by(-10)
    end

    it "should deal hole card to players" do
      expect {
        round_manager.start_new_round(table)
      }.to change { player1.hole_card.size }.by(2)
      .and change { player2.hole_card.size }.by(2)
    end

    it "should not ask blind player in preflop" do
      expect(broadcaster).to receive(:ask).with(0, "ask")

      round_manager.start_new_round(table)
    end

    context "when finished in PREFLOP" do

      before {
        round_manager.start_new_round(table)
      }

      it "should reach showdown without asking and finish round" do
        expect(finish_callback).to receive(:call).with([player2], {0=>0, 1=>15})

        round_manager.apply_action(table, 'fold', nil, action_checker)
      end

    end

    describe "forward next street" do

      describe "PREFLOP to FLOP" do
        before { round_manager.start_new_round(table) }

        it "should forward to flop" do
          expect(broadcaster).to receive(:ask).with(table.dealer_btn, anything)
          expect(broadcaster).to receive(:notification).with("street starts")

          expect {
            round_manager.apply_action(table, 'call', 10, action_checker)
          }.to change { round_manager.street }.to(RoundManager::FLOP)
          .and change { table.community_card.cards.size }.from(0).to(3)
        end
      end

      describe "FLOP to TURN" do
        before {
          round_manager.start_new_round(table)
          round_manager.apply_action(table, 'call', 10, action_checker)
          expect(round_manager.street).to eq RoundManager::FLOP
        }

        it "should forward to TURN" do
          round_manager.apply_action(table, 'raise', 10, action_checker)
          expect(broadcaster).to receive(:ask).with(table.dealer_btn, anything)
          expect(broadcaster).to receive(:notification).with("street starts")

          expect {
            round_manager.apply_action(table, 'call', 10, action_checker)
          }.to change { round_manager.street }.to(RoundManager::TURN)
          .and change { table.community_card.cards.size }.from(3).to(4)
        end
      end

      describe "TURN to RIVER" do
        before {
          round_manager.start_new_round(table)
          round_manager.apply_action(table, 'call', 10, action_checker)
          round_manager.apply_action(table, 'raise', 10, action_checker)
          round_manager.apply_action(table, 'call', 10, action_checker)
          expect(round_manager.street).to eq RoundManager::TURN
        }

        it "should forward to RIVER" do
          round_manager.apply_action(table, 'call', 0, action_checker)
          expect(broadcaster).to receive(:ask).with(table.dealer_btn, anything)
          expect(broadcaster).to receive(:notification).with("street starts")

          expect {
            round_manager.apply_action(table, 'call', 0, action_checker)
          }.to change { round_manager.street }.to(RoundManager::RIVER)
          .and change { table.community_card.cards.size }.from(4).to(5)
        end
      end

      describe "RIVER to SHOWOFF" do
        before {
          round_manager.start_new_round(table)
          round_manager.apply_action(table, 'call', 10, action_checker)
          round_manager.apply_action(table, 'call', 0, action_checker)
          round_manager.apply_action(table, 'call', 0, action_checker)
          round_manager.apply_action(table, 'call', 0, action_checker)
          round_manager.apply_action(table, 'call', 0, action_checker)
          expect(round_manager.street).to eq RoundManager::RIVER
        }

        describe "evaluate the game" do

          before {
            allow(finish_callback).to receive(:call)
          }

          it "should forward to SHOWDOWN" do
            expect {
              round_manager.apply_action(table, 'call', 0, action_checker)
              round_manager.apply_action(table, 'call', 0, action_checker)
            }.to change { round_manager.street }.to(RoundManager::SHOWDOWN)
          end

          it "should update player's stack by game result" do
            round_manager.apply_action(table, 'call', 0, action_checker)
            round_manager.apply_action(table, 'call', 0, action_checker)

            expect(table.seats.players[0].stack).to eq 90
            expect(table.seats.players[1].stack).to eq 110
          end

          it "should invoke callback with winner = player2" do
            expect(finish_callback).to receive(:call).with([player2], { 0 => 0, 1=>20 })

            round_manager.apply_action(table, 'call', 0, action_checker)
            round_manager.apply_action(table, 'call', 0, action_checker)
          end

          it "should clear the round state for next round" do
            round_manager.apply_action(table, 'call', 0, action_checker)
            round_manager.apply_action(table, 'call', 0, action_checker)

            expect(table.community_card.cards.size).to eq 0
            expect(table.deck.size).to eq cheat_deck.size
          end
        end

      end

    end

  end

  describe "play a round with three player" do
    let(:table) { Table.new }
    let(:player1) { PokerPlayer.new(100) }
    let(:player2) { PokerPlayer.new(100) }
    let(:player3) { PokerPlayer.new(100) }

    before {
      for player in [player1, player2, player3] do
        table.seats.sitdown(player)
      end
    }

    describe "PREFLOP to FLOP" do

      describe "one player call and another is fold" do

        it "should forward to FLOP" do
          round_manager.start_new_round(table)
          round_manager.apply_action(table, 'call', 10, action_checker)

          expect(broadcaster).to receive(:ask).with(table.dealer_btn, "ask")

          expect {
            round_manager.apply_action(table, 'fold', nil, action_checker)
          }.to change { round_manager.street }.to(RoundManager::FLOP)
          .and change { table.community_card.cards.size }.from(0).to(3)
        end
      end

    end

  end

end

