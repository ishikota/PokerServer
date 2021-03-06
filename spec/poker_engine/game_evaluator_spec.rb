require 'rails_helper'

RSpec.describe GameEvaluator do

  let(:table) { double("table") }
  let(:seats) { double("seats") }
  let(:players) { [] }
  let(:community_card) { double("community card") }
  let(:hand_evaluator) { double("hand evaluator") }
  let(:game_evaluator) { GameEvaluator.new(hand_evaluator) }

  before {
    allow(table).to receive_message_chain('community_card.cards')
    allow(table).to receive_message_chain('seats.players').and_return(players)
    allow(hand_evaluator).to receive(:eval_hand)
  }

  describe "#judge" do

    let(:pay_till_end) { PokerPlayer::PayInfo::PAY_TILL_END }
    let(:folded) { PokerPlayer::PayInfo::FOLDED }
    let(:allin) { PokerPlayer::PayInfo::ALLIN }

    describe "without all-in player" do

      before {
        3.times do |i|
          player = create_player_with_pay_info(i, 5, pay_till_end)
          allow(player).to receive(:hole_card)
          allow(player).to receive(:active?).and_return(true)
          players << player
        end
        allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 0, 0, 1, 0)
      }

      describe "second player is winner" do

        it "should return winner and prize distribution" do
          winner, prize_map = game_evaluator.judge(table)
          expect(winner.size).to eq 1
          expect(winner).to include players[1]
          expect(prize_map[1]).to eq 15
        end
      end

      context "but second player is folded the game" do

        before {
          allow(hand_evaluator).to receive(:eval_hand).and_return(0, 0)
          allow(players[1]).to receive(:active?).and_return(false)
        }

        it "should not choose second player as winner" do
          winners, prize_map = game_evaluator.judge(table)
          expect(winners.size).to eq 2
          expect(prize_map[0]).to eq 7
          expect(prize_map[2]).to eq 7
        end
      end

    end

    describe "when all-in player exists" do

      before {
        players << create_player_with_pay_info("A", 50, pay_till_end)
        players << create_player_with_pay_info("B", 20, allin)
        players << create_player_with_pay_info("C", 30, allin)
        players.each do |player|
          allow(player).to receive(:hole_card)
          allow(player).to receive(:active?).and_return(true)
        end
      }

      context "and all-in player wins" do

        example "B win (hand rank = B > C > A)" do
          allow(hand_evaluator).to receive(:eval_hand).and_return(0,2,1,0,2,1,0,2,1)
          winners, prize_map = game_evaluator.judge(table)

          expect(prize_map[0]).to eq 20
          expect(prize_map[1]).to eq 60
          expect(prize_map[2]).to eq 20
        end

        example "B win (hand rank = B > A > C)" do
          allow(hand_evaluator).to receive(:eval_hand).and_return(1,2,0,1,2,0,1,0)
          winners, prize_map = game_evaluator.judge(table)

          expect(prize_map[0]).to eq 40
          expect(prize_map[1]).to eq 60
          expect(prize_map[2]).to eq 0
        end

      end

      context "but all-in player does not win" do

        example "A win (hand rank = A > B > C)" do
          allow(hand_evaluator).to receive(:eval_hand).and_return(2,1,0,2,1,0,2,0)
          winners, prize_map = game_evaluator.judge(table)

          expect(prize_map[0]).to eq 100
          expect(prize_map[1]).to eq 0
          expect(prize_map[2]).to eq 0
        end
      end

    end

  end

  describe "#find_winners_from" do
    let(:community_card) { double("community_card") }

    before {
      3.times do |i|
        player = double("player#{i}")
        allow(player).to receive(:hole_card)
        allow(player).to receive(:active?).and_return(true)
        players << player
      end
    }

    context "when winner is second player" do

      before {
        allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 0)
      }

      it "should return second player" do
        winner = game_evaluator.find_winners_from(community_card, players)
        expect(winner.size).to eq 1
        expect(winner).to include players[1]
      end

    end

    context "when second and third  players have same strength" do

      before {
        allow(hand_evaluator).to receive(:eval_hand).and_return(0, 1, 1)
      }

      it "should return second and third player" do
        winner = game_evaluator.find_winners_from(table, players)
        expect(winner.size).to eq 2
        expect(winner).to include players[1]
        expect(winner).to include players[2]
      end

    end

  end

  describe "#create_pot" do

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
        pots = game_evaluator.create_pot(players.values)
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
        pots = game_evaluator.create_pot(players.values)
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
        pots = game_evaluator.create_pot(players.values)
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
        pots = game_evaluator.create_pot(players.values)
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
        pots = game_evaluator.create_pot(players.values)
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
