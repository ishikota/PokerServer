require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("finish_callback") }
  let(:broadcaster) { double("broadcaster") }
  let(:round_manager) { RoundManager.new(broadcaster, finish_callback) }

  describe "player a round" do
    let(:table) { Table.new }
    let(:player1) { PokerPlayer.new(100) }
    let(:player2) { PokerPlayer.new(100) }

    before {
      table.seats.sitdown(player1)
      table.seats.sitdown(player2)
      allow(broadcaster).to receive(:ask)
    }

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
        round_manager.start_new_round(table)
        round_manager.apply_action(table, 'fold', nil)
      }

      it "should reach showoff without asking" do
        expect(round_manager.street).to eq RoundManager::SHOWDOWN
      end
    end

  end

end

