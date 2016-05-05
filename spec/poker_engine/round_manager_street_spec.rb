require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("dealer.finish_round") }
  let(:table) { setup_table }
  let(:seats) { table.seats }
  let(:broadcaster) { double("broadcaster") }
  let(:game_evaluator) { double("game evaluator") }
  let(:round_manager) { RoundManager.new(broadcaster, game_evaluator) }

  before {
    allow(broadcaster).to receive(:ask)
    allow(broadcaster).to receive(:notification)

    round_manager.set_finish_callback(finish_callback)
  }

  describe "#preflop" do

    before {
      allow(seats).to receive(:size).and_return(3)
    }

    it "should ask action to player who sits next to blind player" do
      expect(broadcaster).to receive(:ask).with(2, anything)

      round_manager.start_street(RoundManager::PREFLOP, table)
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
      expect(broadcaster).to receive(:ask).with(0, anything)

      round_manager.start_street(RoundManager::FLOP, table)
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
      expect(broadcaster).to receive(:ask).with(0, anything)

      round_manager.start_street(RoundManager::TURN, table)
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
      expect(broadcaster).to receive(:ask).with(0, anything)

      round_manager.start_street(RoundManager::RIVER, table)
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

