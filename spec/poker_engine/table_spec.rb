require 'rails_helper'

RSpec.describe Table do

  let(:table) { Table.new }

  describe "has game component" do

    it "should respond to " do
      expect(table.dealer_btn).to be_a Fixnum
      expect(table.seats).to be_a Seats
      expect(table.pot).to be_a Pot
      expect(table.deck).to be_a Deck
      expect(table.community_card).to be_a CommunityCard
    end
  end

  describe "reset" do

    before {
      table.pot.add_chip(53)
      5.times { table.community_card.add(table.deck.draw_card) }
    }

    it "should clear pot" do
      expect { table.reset }.to change {
        table.pot.main
      }.to(0)
    end

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

  end

end

