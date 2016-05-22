require 'rails_helper'

RSpec.describe RoundManager do

  let(:game_evaluator) { double("game evaluator") }
  let(:message_builder) { double("message_builder") }
  let(:round_manager) { RoundManager.new(game_evaluator, message_builder) }

  before {
    allow(message_builder).to receive(:round_start_message)
    allow(message_builder).to receive(:street_start_message)
    allow(message_builder).to receive(:ask_message)
  }

  describe "#start_new_round" do
    let(:table) { setup_table }
    let(:deck) { table.deck }
    let(:seats) { table.seats }
    let(:player1) { seats.players[0] }
    let(:player2) { seats.players[1] }

    it "should send round_start and street start message" do
      expect(message_builder).to receive(:round_start_message)
      expect(message_builder).to receive(:street_start_message)
      expect(message_builder).to receive(:ask_message)

      round_manager.start_new_round(1, table)
    end

    it "should collect blind" do
      small_blind = 5  #TODO read blind amount from somewhare
      expect(player1).to receive(:collect_bet).with(small_blind)
      expect(player2).to receive(:collect_bet).with(small_blind * 2)
      expect(player1.pay_info).to receive(:update_by_pay).with(small_blind)
      expect(player2.pay_info).to receive(:update_by_pay).with(small_blind * 2)

      round_manager.start_new_round(1, table)
    end

    it "should deal hole card to players" do
      seats.players.each { |player|
        expect(player).to receive(:add_holecard).with([anything, anything])
      }

      round_manager.start_new_round(1, table)
    end

  end

  describe "#shift_next_player" do
    let(:seats) { double("seats") }
    let(:players) {
      (1..3).inject([]) do |ary, i|
        player = double("player#{i}")
        allow(player).to receive(:active?).and_return(true)
        ary << player
      end
    }

    before {
      allow(seats).to receive(:size).and_return(3)
      allow(seats).to receive(:players).and_return(players)
    }

    context "when next player is active" do

      it "should shift next player to second player" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 1
      end

    end

    context "when next player is not active" do

      before {
        allow(players[1]).to receive(:active?).and_return(false)
      }

      it "should skip the person" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 2
      end

    end

    describe "cycle ask order" do

      before do
        2.times { round_manager.shift_next_player(seats) }
      end

      it "should shift next player to first player" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 0
      end

    end
  end

  private

    def setup_table
      table = double("table")
      allow(table).to receive(:dealer_btn).and_return(0)
      allow(table).to receive(:seats).and_return seat_with_active_players
      allow(table).to receive(:deck).and_return deck_with_cards
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
        allow(player).to receive(:add_holecard)
        allow(player).to receive(:collect_bet)
        allow(player).to receive(:pay_info).and_return pay_info
        allow(player).to receive(:paid_sum).and_return 0
        allow(pay_info).to receive(:amount).and_return(0)
        allow(pay_info).to receive(:update_by_pay)
        acc << player
      end

      seats = double("seats")
      allow(seats).to receive(:players).and_return(players)
      allow(seats).to receive(:size).and_return 3
      allow(seats).to receive(:count_active_player).and_return 3
      allow(seats).to receive(:count_ask_wait_players).and_return 3
      return seats
    end

    def deck_with_cards
      deck = double("deck")
      card = double("card")
      allow(card).to receive(:is_a?).with(Card).and_return(true)
      allow(deck).to receive(:draw_cards).and_return([card, card])
      allow(deck).to receive(:shuffle)
      deck
    end

end

