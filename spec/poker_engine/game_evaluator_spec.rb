require 'rails_helper'

RSpec.describe GameEvaluator do

  let(:table) { double("table") }
  let(:seats) { double("seats") }
  let(:players) { [] }
  let(:community_card) { double("community card") }
  let(:hand_evaluator) { double("hand evaluator") }
  let(:game_evaluator) { GameEvaluator.new(hand_evaluator) }

  before {
    allow(table).to receive(:community_card).and_return(community_card)
    allow(table).to receive(:seats).and_return(seats)
    allow(seats).to receive(:players).and_return(players)
    allow(hand_evaluator).to receive(:eval_hand)
    allow(community_card).to receive(:cards)
  }

  describe "#judge" do

    before {
      3.times do |i|
        player = create_player_with_pay_info(i, 5, PokerPlayer::PayInfo::PAY_TILL_END)
        allow(player).to receive(:hole_card)
        players << player
      end
    }

    describe "without all-in player" do

      describe "second player is winner" do

        before {
          allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 0)
        }

        it "should return winner and prize distribution" do
          winner, prize_map = game_evaluator.judge(table)
          expect(winner.size).to eq 1
          expect(winner).to include players[1]
          expect(prize_map[1]).to eq 15
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

  describe "#create_side_pot" do

    let(:pay_till_end) { PokerPlayer::PayInfo::PAY_TILL_END }
    let(:folded) { PokerPlayer::PayInfo::FOLDED }
    let(:allin) { PokerPlayer::PayInfo::ALLIN }

    let(:players) { {} }

    context "A: $50, B: $20(ALLIN),  C: $30(ALLIN)" do

      before {
        players.merge!( { A: create_player_with_pay_info("A", 50, pay_till_end) } )
        players.merge!( { B: create_player_with_pay_info("B", 20, allin) } )
        players.merge!( { C: create_player_with_pay_info("C", 30, allin) } )
      }

      it "should create side pot with eligible players" do
        pots = game_evaluator.create_side_pot(players.values)
        expect(pots.size).to eq 3
        sidepot_check(players, pots[0], 60, [:A, :B, :C])
        sidepot_check(players, pots[1], 20, [:A, :C])
        sidepot_check(players, pots[2], 20, [:A])
      end

    end

    context "A: $10, B: $10,  C: $7(ALLIN), D: $10" do

      before {
        players.merge!( { A: create_player_with_pay_info("A", 10, pay_till_end) } )
        players.merge!( { B: create_player_with_pay_info("B", 10, pay_till_end) } )
        players.merge!( { C: create_player_with_pay_info("C", 7, allin) } )
      }

      it "should create side pot with eligible players" do
        pots = game_evaluator.create_side_pot(players.values)
        expect(pots.size).to eq 2
        sidepot_check(players, pots[0], 21, [:A, :B, :C])
        sidepot_check(players, pots[1], 6, [:A, :B])
      end
    end

    context "A: $20(FOLD), B: $30, C: $7(ALLIN), D: $30" do

      before {
        players.merge!( { A: create_player_with_pay_info("A", 20, folded) } )
        players.merge!( { B: create_player_with_pay_info("B", 30, pay_till_end) } )
        players.merge!( { C: create_player_with_pay_info("C", 7, allin) } )
        players.merge!( { D: create_player_with_pay_info("D", 30, pay_till_end) } )
      }

      it "should create side pot with eligible players" do
        pots = game_evaluator.create_side_pot(players.values)
        expect(pots.size).to eq 2
        sidepot_check(players, pots[0], 28, [:B, :C, :D])
        sidepot_check(players, pots[1], 59, [:B, :D])
      end

    end

    context "A: $12(ALLIN), B: $30, C: $7(ALLIN), D: $30" do

      before {
        players.merge!( { A: create_player_with_pay_info("A", 12, allin) } )
        players.merge!( { B: create_player_with_pay_info("B", 30, pay_till_end) } )
        players.merge!( { C: create_player_with_pay_info("C", 7, allin) } )
        players.merge!( { D: create_player_with_pay_info("D", 30, pay_till_end) } )
      }

      it "should create side pot with eligible players" do
        pots = game_evaluator.create_side_pot(players.values)
        expect(pots.size).to eq 3
        sidepot_check(players, pots[0], 28, [:A, :B, :C, :D])
        sidepot_check(players, pots[1], 15, [:A, :B, :D])
        sidepot_check(players, pots[2], 36, [:B, :D])
      end

    end

    context "A: $5(ALLIN), B: $10, C: $8(ALLIN), D: $10, E: $2(FOLDED)" do

      before {
        players.merge!( { A: create_player_with_pay_info("A", 5, allin) } )
        players.merge!( { B: create_player_with_pay_info("B", 10, pay_till_end) } )
        players.merge!( { C: create_player_with_pay_info("C", 8, allin) } )
        players.merge!( { D: create_player_with_pay_info("D", 10, pay_till_end) } )
        players.merge!( { E: create_player_with_pay_info("E", 2, folded) } )
      }

      it "should create side pot with eligible players" do
        pots = game_evaluator.create_side_pot(players.values)
        expect(pots.size).to eq 3
        sidepot_check(players, pots[0], 22, [:A, :B, :C, :D])
        sidepot_check(players, pots[1], 9, [:B, :C, :D])
        sidepot_check(players, pots[2], 4, [:B, :D])
      end

    end

  end

  private

    def create_player_with_pay_info(name, amount, status)
      player = double("player #{name}")
      pay_info = create_pay_info(amount, status)
      allow(player).to receive(:name).and_return name
      allow(player).to receive(:pay_info).and_return pay_info
      return player
    end

    def create_pay_info(amount, status)
      pay_info = double("pay_info")
      allow(pay_info).to receive(:amount).and_return amount
      allow(pay_info).to receive(:status).and_return status
      return pay_info
    end

    def sidepot_check(players, pot, amount, eligibles)
      expect(pot[:amount]).to eq amount
      expect(pot[:eligibles].size).to eq eligibles.size
      for name in eligibles
        expect(pot[:eligibles]).to include players[name]
      end
    end


end
