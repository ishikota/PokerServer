require 'rails_helper'
require 'features/feature_spec_helper'

RSpec.describe Dealer do
  include FeatureSpecHelper

  let(:finish_callback) { double("finish_callback") }
  let(:broadcaster) { double("broadcaster") }
  let(:dealer) { Dealer.new(components_holder) }
  let(:config) { Config.new(initial_stack=20, max_round=2) }
  let(:table) { Table.new(cheat_deck) }
  let(:hand_evaluator) { HandEvaluator.new }
  let(:game_evaluator) { GameEvaluator.new(hand_evaluator) }
  let(:message_builder) { double("message_builder") }
  let(:round_manager) { RoundManager.new(broadcaster, game_evaluator, message_builder) }
  let(:action_checker) { ActionChecker.new }
  let(:player_maker) { PlayerMaker.new }

  let(:components_holder) do
    {
      broadcaster: broadcaster,
      config: config,
      table: table,
      round_manager: round_manager,
      action_checker: action_checker,
      player_maker: player_maker,
      message_builder: message_builder
    }
  end

  let(:game_start_msg) { "game results" }
  let(:round_start_msg) { "round starts" }
  let(:street_start_msg) { "street starts" }
  let(:ask_msg) { "ask" }
  let(:update_msg) { "update" }
  let(:round_result_msg) { "round results" }
  let(:game_result_msg) { "game results" }

  before {
    allow(broadcaster).to receive(:ask)
    allow(broadcaster).to receive(:notification)
    allow(finish_callback).to receive(:call)
    allow(message_builder).to receive(:game_start_message).and_return(game_start_msg)
    allow(message_builder).to receive(:round_start_message).and_return(round_start_msg)
    allow(message_builder).to receive(:street_start_message).and_return(street_start_msg)
    allow(message_builder).to receive(:ask_message).and_return(ask_msg)
    allow(message_builder).to receive(:game_update_message).and_return(update_msg)
    allow(message_builder).to receive(:round_result_message).and_return(round_result_msg)
    allow(message_builder).to receive(:game_result_message).and_return(game_result_msg)
  }

  describe "play a round" do
    let(:config) { Config.new(initial_stack=100, max_round=1) }

    before { dealer.start_game(create_players_info(2)) }

    it "should finish by player 1 win" do
      dealer.receive_data(0, call_msg(10))
      dealer.receive_data(0, raise_msg(10))
      dealer.receive_data(1, fold_msg)

      expect(table.seats.players[0].stack).to eq 110
      expect(table.seats.players[1].stack).to eq 90
    end

    it "should finish by player 2 win" do
      play_a_round(dealer)

      expect(table.seats.players[0].stack).to eq 90
      expect(table.seats.players[1].stack).to eq 110
    end

  end

  describe "play two rounds successibly" do
    let(:config) { Config.new(initial_stack=100, max_round=2) }

    before {
      expect(message_builder).to receive(:round_start_message).with(0, anything).twice
      expect(broadcaster).to receive(:notification).with(round_result_msg).twice
      expect(broadcaster).to receive(:notification).with(game_result_msg)

      dealer.start_game(create_players_info(2))
    }

    context "just call both of players untill end" do

      it "should finish by player 2 win" do
        play_a_round(dealer)
        play_a_round(dealer)

        expect(table.seats.players[0].stack).to eq 80
        expect(table.seats.players[1].stack).to eq 120
      end
    end

    context "one player fold the first game" do

      it "should activate folded player in teardown raound" do
        # first round
        dealer.receive_data(0, call_msg(10))
        dealer.receive_data(0, raise_msg(10))
        dealer.receive_data(1, fold_msg)
        # second round
        play_a_round(dealer)

        expect(table.seats.players[0].stack).to eq 100
        expect(table.seats.players[1].stack).to eq 100
      end
    end

  end

  describe "Count allin player as agreed" do
    let(:config) { Config.new(initial_stack=100, max_round=2) }

    before "update player's stack to p1.stack=50, p2.stack=150" do
      dealer.start_game(create_players_info(2))
      dealer.receive_data(0, raise_msg(50))
      dealer.receive_data(1, call_msg(50))
      dealer.receive_data(0, call_msg(0))
      dealer.receive_data(1, call_msg(0))
      dealer.receive_data(0, call_msg(0))
      dealer.receive_data(0, call_msg(0))
      dealer.receive_data(1, call_msg(0))
      dealer.receive_data(1, call_msg(0))

      # Round 2 : small blind = p2, big blind = p1
      expect(table.seats.players[0].stack).to eq 50 - 10
      expect(table.seats.players[1].stack).to eq 150 - 5
    end

    it "should forward to SHOWDOWN after p1's allin" do
      expect(broadcaster).to receive(:notification).with(game_result_msg)

      dealer.receive_data(1, call_msg(10))
      dealer.receive_data(1, call_msg(0))
      dealer.receive_data(0, raise_msg(40))
      dealer.receive_data(1, call_msg(40))

      expect(table.seats.players[0].stack).to eq 0
      expect(table.seats.players[1].stack).to eq 200
    end
  end

  private

    def create_players_info(size)
      (1..size).inject([]) { |ary, idx|
        ary << { "name" => "player #{idx}" }
      }
    end

    def play_a_round(dealer)
      dealer.receive_data(0, call_msg(10))
      # FLOP start
      dealer.receive_data(0, call_msg(0))
      dealer.receive_data(1, call_msg(0))
      # TURN start
      dealer.receive_data(0, call_msg(0))
      dealer.receive_data(1, call_msg(0))
      # RIVER start
      dealer.receive_data(0, call_msg(0))
      dealer.receive_data(1, call_msg(0))
    end

    def call_msg(bet_amount)
      base_msg("call", bet_amount)
    end

    def fold_msg
      base_msg("fold", 0)
    end

    def raise_msg(bet_amount)
      base_msg("raise", bet_amount)
    end

    def base_msg(action, bet_amount)
      { "action" => action, "bet_amount" => bet_amount }
    end

end

