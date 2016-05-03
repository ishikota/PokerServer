require 'rails_helper'

RSpec.describe Dealer do

  let(:finish_callback) { double("finish_callback") }
  let(:broadcaster) { double("broadcaster") }
  let(:dealer) { Dealer.new(components_holder) }
  let(:config) { Config.new(initial_stack=20, max_round=2) }
  let(:table) { Table.new(cheat_deck) }
  let(:hand_evaluator) { HandEvaluator.new }
  let(:game_evaluator) { GameEvaluator.new(hand_evaluator) }
  let(:round_manager) { RoundManager.new(broadcaster, game_evaluator) }
  let(:action_checker) { ActionChecker.new }
  let(:player_maker) { PlayerMaker.new }

  let(:components_holder) do
    {
      broadcaster: broadcaster,
      config: config,
      table: table,
      round_manager: round_manager,
      action_checker: action_checker,
      player_maker: player_maker
    }
  end

  describe "play a round" do
    let(:config) { Config.new(initial_stack=100, max_round=0) }

    before {
      allow(broadcaster).to receive(:ask)
      allow(broadcaster).to receive(:notification)
      allow(finish_callback).to receive(:call)
    }

    it "should finish by player 2 win" do
      dealer.start_game(["dummy", "info"])
      dealer.receive_data(0, call_action_message(10))
      # FLOP start
      dealer.receive_data(0, call_action_message(0))
      dealer.receive_data(1, call_action_message(0))
      # TURN start
      dealer.receive_data(0, call_action_message(0))
      dealer.receive_data(1, call_action_message(0))
      # RIVER start
      dealer.receive_data(0, call_action_message(0))
      dealer.receive_data(1, call_action_message(0))

      expect(table.seats.players[0].stack).to eq 90
      expect(table.seats.players[1].stack).to eq 110
    end

  end


  private

    def call_action_message(bet_amount)
      { "action" => "call", "bet_amount" => bet_amount }
    end

    C = Card::CLUB
    D = Card::DIAMOND
    H = Card::HEART
    S = Card::SPADE

    def cheat_deck
      p1_hole = [card(C,9), card(D,2)]  # no pair
      p2_hole = [card(C,8), card(D,3)]  # one pair
      flop_community = [card(D,3), card(D,5), card(C, 7)]
      turn_community = card(D,6)
      river_community = card(C,10)

      cards = [] << p1_hole << p2_hole \
          << flop_community << turn_community << river_community

      Deck.new(cheat=true, cheat_cards=cards.flatten)
    end

    def card(suit, rank)
      Card.new(suit, rank)
    end

end

