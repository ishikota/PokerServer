require 'rails_helper'
require 'poker_engine/round_manager_spec_helper'

RSpec.describe RoundManager do
  include RoundManagerSpecHelper

  let(:finish_callback) { double("dealer.finish_round") }
  let(:table) { setup_table }
  let(:seats) { table.seats }
  let(:player1) { table.seats.players[0] }
  let(:player2) { table.seats.players[1] }
  let(:player3) { table.seats.players[2] }
  let(:game_evaluator) { double("game evaluator") }
  let(:message_builder) { double("message_builder") }
  let(:round_manager) { RoundManager.new(game_evaluator, message_builder) }

  before {
    allow(message_builder).to receive(:round_start_message)
    allow(message_builder).to receive(:street_start_message)
    allow(message_builder).to receive(:ask_message)

    round_manager.set_finish_callback(finish_callback)
  }

  describe "#preflop" do

    before {
      allow(seats).to receive(:size).and_return(3)
    }

    it "should ask action to player who sits next to blind player" do
      msgs = round_manager.start_street(RoundManager::PREFLOP, table)
      expect(msgs).to include ask_msg(player3.uuid, anything)
      expect(round_manager.next_player).to eq 2
    end

  end

  describe "#flop" do
    let(:deck) { table.deck }
    let(:community_card) { table.community_card }

    it "should add three commnity card" do
      expect(community_card).to receive(:add).with("card1")
      expect(community_card).to receive(:add).with("card2")
      expect(community_card).to receive(:add).with("card3")

      round_manager.start_street(RoundManager::FLOP, table)
    end

    it "should ask action to player who has dealer button"  do
      allow(community_card).to receive(:add)

      msgs = round_manager.start_street(RoundManager::FLOP, table)
      expect(msgs).to include ask_msg(player1.uuid, anything)
      expect(round_manager.next_player).to eq 0
    end

  end

  describe "#turn" do
    let(:deck) { table.deck }
    let(:community_card) { table.community_card }

    it "should add a community card" do
      expect(community_card).to receive(:add).with("card1")

      round_manager.start_street(RoundManager::TURN, table)
    end

    it "should ask action to player who has dealer button" do
      allow(community_card).to receive(:add)

      msgs = round_manager.start_street(RoundManager::TURN, table)
      expect(msgs).to include ask_msg(player1.uuid, anything)
      expect(round_manager.next_player).to eq 0
    end

  end

  describe "#river" do
    let(:deck) { table.deck }
    let(:community_card) { table.community_card }

    it "should add a community card" do
      expect(community_card).to receive(:add).with("card1")

      round_manager.start_street(RoundManager::RIVER, table)
    end

    it "should ask action to player who has dealer button" do
      allow(community_card).to receive(:add)

      msgs = round_manager.start_street(RoundManager::RIVER, table)
      expect(msgs).to include ask_msg(player1.uuid, anything)
      expect(round_manager.next_player).to eq 0
    end

  end

  describe "#showdown" do
    let(:winner) { seats.players[1] }
    let(:accounting_info) { { 1 => 20 } }

    before {
      allow(finish_callback).to receive(:call)
      allow(game_evaluator).to receive(:judge)
          .and_return([[winner], accounting_info])
      allow(table).to receive(:reset)
      allow(winner).to receive(:append_chip)
    }

    it "should clear table state like before the round" do
      expect(table).to receive(:reset)

      round_manager.start_street(RoundManager::SHOWDOWN, table)
    end

    it "should call dealer's callback with game result" do
      expect(finish_callback).to receive(:call).with([winner], accounting_info)

      round_manager.start_street(RoundManager::SHOWDOWN, table)
    end

    it "should give prize to winner" do
      loser = seats.players[0]
      expect(winner).to receive(:append_chip).with(20)
      expect(loser).not_to receive(:append_chip)

      round_manager.start_street(RoundManager::SHOWDOWN, table)
    end

  end


  private

    def setup_table
      table = double("table")
      allow(table).to receive(:dealer_btn).and_return(0)
      allow(table).to receive(:seats).and_return seat_with_active_players
      allow(table).to receive(:deck).and_return setup_deck
      allow(table).to receive(:community_card).and_return double("community_card")
      return table
    end

    def seat_with_active_players
      players =  (1..3).inject([]) do |acc, i|
        player = double("player#{i}")
        pay_info = double("pay info #{i}")
        allow(player).to receive(:uuid).and_return("uuid-#{i}")
        allow(player).to receive(:active?).and_return(true)
        allow(player).to receive(:clear_action_histories)
        allow(player).to receive(:clear_pay_info)
        allow(player).to receive(:add_action_history)
        allow(player).to receive(:pay_info).and_return pay_info
        allow(player).to receive(:paid_sum).and_return 0
        allow(pay_info).to receive(:amount).and_return(0)
        acc << player
      end

      seats = double("seats")
      allow(seats).to receive(:players).and_return(players)
      allow(seats).to receive(:count_active_player).and_return 2
      allow(seats).to receive(:count_ask_wait_players).and_return 3
      return seats
    end

    def setup_deck
      deck = double("deck")
      allow(deck).to receive(:draw_cards).and_return(["card1", "card2", "card3"])
      allow(deck).to receive(:draw_card).and_return("card1")
      return deck
    end

end

