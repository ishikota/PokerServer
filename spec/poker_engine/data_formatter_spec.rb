require 'rails_helper'
require 'features/feature_spec_helper'
require 'poker_engine/object_initialize_helper'

RSpec.describe DataFormatter do
  include FeatureSpecHelper
  include ObjectInitializeHelper

  let(:game_evaluator) { GameEvaluator.new(hand_evaluator=nil) }
  let(:formatter) { DataFormatter.new(game_evaluator) }

  describe "player" do
    let(:player) { setup_player }

    it "should convert player into hash" do
      data = formatter.format_player(player)
      expect(data["name"]).to eq "hoge"
      expect(data["stack"]).to eq 100
      expect(data["state"]).to eq 0
      expect(data["hole_card"]).to be_nil
      expect(data["action_histories"]).to be_nil
      expect(data["pay_info"]).to be_nil
    end

    context "with holecard" do

      it "should include hole card" do
        data = formatter.format_player(player, holecard=true)
        expect(data["hole_card"]).to eq ["C9", "D2"]
      end
    end

  end

  describe "seat" do
    let(:seats) { setup_seats_with_players(2) }

    it "should convert seats into hash" do
      data = formatter.format_seats(seats)
      expect(data["seats"].size).to eq 2
      expect(data["seats"].first).to eq formatter.format_player(seats.players.first)
    end
  end

  describe "pot" do

    let(:pay_till_end) { PokerPlayer::PayInfo::PAY_TILL_END }
    let(:folded) { PokerPlayer::PayInfo::FOLDED }
    let(:allin) { PokerPlayer::PayInfo::ALLIN }

    let(:players) { [] }

    context "A: $5, B: $10, C:$10" do

      before {
        players << create_player_with_pay_info("A",  5, pay_till_end)
        players << create_player_with_pay_info("B", 10, pay_till_end)
        players << create_player_with_pay_info("C", 10, pay_till_end)
      }

      it "should convert pots into hash" do
        data = formatter.format_pot(players)
        main_pot = data["main"]

        expect(main_pot["amount"]).to eq 25
        expect(main_pot["eligibles"]).to be_nil
        expect(data["side"]).to be_empty
      end
    end


    context "A: $5(ALLIN), B: $10, C: $8(ALLIN), D: $10, E: $2(FOLDED)" do

      before {
        players << create_player_with_pay_info("A", 5, allin)
        players << create_player_with_pay_info("B", 10, pay_till_end)
        players << create_player_with_pay_info("C", 8, allin)
        players << create_player_with_pay_info("D", 10, pay_till_end)
        players << create_player_with_pay_info("E", 2, folded)
      }

      it "should convert pots into hash" do
        data = formatter.format_pot(players)
        main_pot = data["main"]
        side_pot1, side_pot2 = data["side"]

        expect(main_pot["amount"]).to eq 22

        expect(side_pot1["amount"]).to eq 9
        expect(side_pot1["eligibles"].size).to eq 3

        expect(side_pot2["amount"]).to eq 4
        expect(side_pot2["eligibles"].size).to eq 2
      end
    end
  end

  describe "game_information" do
    let(:seats) { setup_seats_with_players(2) }
    let(:config) { Config.new }

    it "should convert game_information into hash" do
      data = formatter.format_game_information(config, seats)
      expect(data["player_num"]).to eq 2
      expect(data["seats"]).to eq formatter.format_seats(seats)
      expect(data["rule"]["small_blind_amount"]).to eq 5
      expect(data["rule"]["max_round"]).to eq 10
      expect(data["rule"]["initial_stack"]).to eq 100
    end

  end

  describe "valid_actions" do

    it "should convert valid actions into hash" do
      data = formatter.format_valid_actions(10, 20, 100)
      expect(data["valid_actions"][0]["action"]).to eq "fold"
      expect(data["valid_actions"][0]["amount"]).to eq 0
      expect(data["valid_actions"][1]["action"]).to eq "call"
      expect(data["valid_actions"][1]["amount"]).to eq 10
      expect(data["valid_actions"][2]["action"]).to eq "raise"
      expect(data["valid_actions"][2]["amount"]["min"]).to eq 20
      expect(data["valid_actions"][2]["amount"]["max"]).to eq 100
    end
  end

  describe "action" do
    let(:player) { setup_player }

    it "should convert action into hash" do
      data = formatter.format_action(player, 'raise', 20)
      expect(data["player"]).to eq formatter.format_player(player)
      expect(data["action"]).to eq 'raise'
      expect(data["amount"]).to eq 20
    end
  end

  describe "street" do

    def check(arg, expected)
      expect(formatter.format_street(arg)["street"]).to eq expected
    end

    it "should convert action into hash" do
      check(RoundManager::PREFLOP, "PREFLOP")
      check(RoundManager::FLOP, "FLOP")
      check(RoundManager::TURN, "TURN")
      check(RoundManager::RIVER, "RIVER")
      check(RoundManager::SHOWDOWN, "SHOWDOWN")
    end

    it "should raise error when unexpected arg is passed" do
      expect {
        formatter.format_street(5)
      }.to raise_error
    end
  end

  describe "action_history" do
    let(:table) { setup_table_with_players(3) }
    let(:player1) { table.seats.players[0] }
    let(:player2) { table.seats.players[1] }
    let(:player3) { table.seats.players[2] }

    before {
      player1.add_action_history(PokerPlayer::ACTION::RAISE, 10, 5)
      player2.add_action_history(PokerPlayer::ACTION::FOLD)
      player3.add_action_history(PokerPlayer::ACTION::RAISE, 20, 10)
      player1.add_action_history(PokerPlayer::ACTION::CALL, 20)
    }

    def check(target, player, action, amount)
      expect(target["player"]).to eq formatter.format_player(player)
      expect(target["action"]).to eq action
      expect(target["amount"]).to eq amount
    end

    it "should convert action_history into hash in correct_order" do
      data = formatter.format_action_histories(table)
      histories = data["action_histories"]
      expect(histories.size).to eq 4
      expect(player1.action_histories.size).to eq 2
      check(histories[0], player1, "RAISE", 10)
      check(histories[1], player2, "FOLD", nil)
      check(histories[2], player3, "RAISE", 20)
      check(histories[3], player1, "CALL", 20)
    end

    context "when dealer button is shifted" do

      before { table.shift_dealer_btn }

      it "should change order of action histories" do
        data = formatter.format_action_histories(table)
        histories = data["action_histories"]
        check(histories[0], player2, "FOLD", nil)
        check(histories[1], player3, "RAISE", 20)
        check(histories[2], player1, "RAISE", 10)
      end
    end

    context "skip folded player" do

      before {
        table.seats.players.first.clear_action_histories
      }

      it "should skip first player actioin history" do
        data = formatter.format_action_histories(table)
        histories = data["action_histories"]
        expect(histories.size).to eq 2
        check(histories[0], player2, "FOLD", nil)
        check(histories[1], player3, "RAISE", 20)
      end
    end
  end

  describe "winners" do
    let(:winners) { setup_players(2) }

    it "should convert winners into hash" do
      data = formatter.format_winners(winners)
      expect(data["winners"].size).to eq 2
      expect(data["winners"].first).to eq formatter.format_player(winners.first)
      expect(data["winners"].last).to eq formatter.format_player(winners.last)
    end
  end

  describe "round_state" do
    let(:round_manager) { create_round_manager }
    let(:table) { setup_table_with_players(2) }

    before {
      action_checler = ActionChecker.new
      round_manager.start_new_round(table)
      round_manager.apply_action(table, 'call', 10, action_checler)  # forward to FLOP
    }

    it "should convert round info into hash" do
      data = formatter.format_round_state(round_manager, table)
      expect(data["street"]).to eq "FLOP"
      expect(data["pot"]).to eq formatter.format_pot(table.seats.players)
      expect(data["seats"]).to eq formatter.format_seats(table.seats)
      expect(data["community_card"]).to eq ["D3", "D5", "C7"]
      expect(data["dealer_btn"]).to eq 0
      expect(data["next_player"]).to eq formatter.format_player(table.seats.players[0])
    end
  end

end
