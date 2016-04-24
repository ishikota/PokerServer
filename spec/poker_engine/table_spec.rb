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

end

