require 'rails_helper'

RSpec.describe Table do

  let(:table) { Table.new }

  describe "has game component" do

    it "should respond to " do
      expect(table.dealer_btn).to be_a Fixnum
      expect(table.seats).to be_a Seats
      expect(table.deck).to be_a Deck
      expect(table.community_card).to be_a CommunityCard
    end
  end

  describe "reset" do
    let(:player) { double("player") }

    before {
      5.times { table.community_card.add(table.deck.draw_card) }
      table.seats.sitdown(player)
      allow(player).to receive(:clear_holecard)
      allow(player).to receive(:clear_action_histories)
      allow(player).to receive(:clear_pay_info)
    }

    it "should reset deck (do not need to shuffle)" do
      expect { table.reset }.to change {
        table.deck.size
      }.to(52)
    end

    it "should clear community card" do
      expect { table.reset }.to change {
        table.community_card.cards.size
      }.to(0)
    end

    it "should reset player action log and hole card" do
      expect(player).to receive(:clear_holecard)
      expect(player).to receive(:clear_action_histories)
      expect(player).to receive(:clear_pay_info)

      table.reset
    end

  end

  describe "shift_dealer_btn" do
    let(:players) do
      (1..3).inject([]) { |acc, i| acc << double("player#{i}") }
    end

    before do
      players.each { |player|
        allow(player).to receive(:active?).and_return(true)
        table.seats.sitdown(player)
      }
    end

    describe "when next player is active" do

      it "should shift to next player" do
        expect {
          table.shift_dealer_btn
        }.to change { table.dealer_btn }.to(1)
      end
    end

    describe "when next player is not active" do

      before {
        allow(players[1]).to receive(:active?).and_return(false)
      }

      it "should skip next player" do
        expect {
          table.shift_dealer_btn
        }.to change { table.dealer_btn }.to(2)
      end
    end

    describe "cycle shift position to head" do

      before {
        2.times { table.shift_dealer_btn }
      }

      it "should shift to first player" do
        expect {
          table.shift_dealer_btn
        }.to change { table.dealer_btn }.to(0)
      end
    end


  end

end

