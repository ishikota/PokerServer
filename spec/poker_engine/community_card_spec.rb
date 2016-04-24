require 'rails_helper'

RSpec.describe CommunityCard do
  let(:community_card) { CommunityCard.new }

  describe "#add" do
    let(:card) { double('card') }

    it "should add card to community card" do
      community_card.add(card)
      expect(community_card.cards).to include card
    end

    context "when community card is already 5" do

      before {
        5.times { community_card.add(card) }
      }

      it "should raise error" do
        expect { community_card.add(card) }.to raise_error
      end
    end
  end

end

