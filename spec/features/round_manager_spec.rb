require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("finish_callback") }
  let(:broadcaster) { double("broadcaster") }
  let(:game_evaluator) { double("game_evaluator") }
  let(:round_manager) { RoundManager.new(broadcaster, finish_callback, game_evaluator) }
  let(:action_checker) { ActionChecker.new }

  before {
    allow(broadcaster).to receive(:notification)
    allow(broadcaster).to receive(:ask)
  }

  describe "player a round with two player" do
    let(:table) { Table.new }
    let(:player1) { PokerPlayer.new(100) }
    let(:player2) { PokerPlayer.new(100) }

    before {
      table.seats.sitdown(player1)
      table.seats.sitdown(player2)
    }

    it "should notify starts of the round to all players" do
      expect(broadcaster).to receive(:notification).with("round info")
      expect(broadcaster).to receive(:notification).with("PREFLOP starts")

      round_manager.start_new_round(table)
    end

    it "should collect blind" do
      expect {
        round_manager.start_new_round(table)
      }.to change { player1.stack }.by(-5)
       .and change { player2.stack }.by(-10)
    end

    it "should not ask blind player in preflop" do
      expect(broadcaster).to receive(:ask).with(0, "TODO")

      round_manager.start_new_round(table)
    end

    context "when finished in PREFLOP" do

      before {
        allow(game_evaluator).to receive(:judge)
        allow(finish_callback).to receive(:call)
        round_manager.start_new_round(table)
        round_manager.apply_action(table, 'fold', nil, action_checker)
      }

      it "should reach showdown without asking" do
        expect(round_manager.street).to eq RoundManager::SHOWDOWN
      end
    end

    describe "forward next street" do

      describe "PREFLOP to FLOP" do
        before { round_manager.start_new_round(table) }

        it "should forward to flop" do
          expect(broadcaster).to receive(:ask).with(table.dealer_btn, anything)
          expect(broadcaster).to receive(:notification).with("FLOP starts")

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
          expect(broadcaster).to receive(:notification).with("TURN starts")

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
          round_manager.apply_action(table, 'raise', 10, action_checker)
          expect(broadcaster).to receive(:ask).with(table.dealer_btn, anything)
          expect(broadcaster).to receive(:notification).with("RIVER starts")

          expect {
            round_manager.apply_action(table, 'call', 10, action_checker)
          }.to change { round_manager.street }.to(RoundManager::RIVER)
          .and change { table.community_card.cards.size }.from(4).to(5)
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

          expect(broadcaster).to receive(:ask).with(table.dealer_btn, "TODO")

          expect {
            round_manager.apply_action(table, 'fold', nil, action_checker)
          }.to change { round_manager.street }.to(RoundManager::FLOP)
          .and change { table.community_card.cards.size }.from(0).to(3)
        end
      end

    end

  end

end

