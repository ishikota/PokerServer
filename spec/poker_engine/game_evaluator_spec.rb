require 'rails_helper'

RSpec.describe GameEvaluator do

  let(:table) { double("table") }
  let(:seats) { double("seats") }
  let(:pot) { double("pot") }
  let(:players) { [] }
  let(:hand_evaluator) { double("hand evaluator") }
  let(:game_evaluator) { GameEvaluator.new(hand_evaluator) }

  before {
    allow(table).to receive(:community_card)
    allow(table).to receive(:pot).and_return(pot)
    allow(table).to receive(:seats).and_return(seats)
    allow(seats).to receive(:players).and_return(players)
    allow(hand_evaluator).to receive(:eval_hand)
  }

  describe "#judge" do

    before {
      3.times do |i|
        player = double("player#{i}")
        allow(player).to receive(:hole_card)
        players << player
      end
    }

    describe "without all-in player" do
      let(:pot_amount) { 10 }
      before {
        allow(pot).to receive(:main).and_return(pot_amount)
      }

      describe "second player is winner" do

        before {
          allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 0)
        }

        it "should return winner and prize distribution" do
          winner, prize_map = game_evaluator.judge(table)
          expect(winner.size).to eq 1
          expect(winner).to include players[1]
          expect(prize_map[1]).to eq pot_amount
        end
      end

    end

    describe "when all-in player exists" do

      context "and all-in player wins" do

        it "should take side pot into consideratino"

      end

      context "but all-in player does not win" do

        it "should give main and side pot to winner"

      end

    end

  end

  describe "#find_winner_from" do
    let(:community_card) { double("community_card") }

    before {
      3.times do |i|
        player = double("player#{i}")
        allow(player).to receive(:hole_card)
        players << player
      end
    }

    context "when winner is second player" do

      before {
        allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 0)
      }

      it "should return second player" do
        winner = game_evaluator.find_winner_from(community_card, players)
        expect(winner.size).to eq 1
        expect(winner).to include players[1]
      end

    end

    context "when second and third  players have same strength" do

      before {
        allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 1)
      }

      it "should return second and third player" do
        winner = game_evaluator.find_winner_from(table, players)
        expect(winner.size).to eq 2
        expect(winner).to include players[1]
        expect(winner).to include players[2]
      end

    end

  end

end
