require 'rails_helper'

RSpec.describe CommunityCard do
  let(:community_card) { CommunityCard.new }
  let(:card) { double('card') }

  describe "#add" do

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

  describe "#clear" do

    before {
      5.times { community_card.add(card) }
    }

    it "should clear the cards" do
      expect { community_card.clear }
          .to change { community_card.cards.size }.to 0
    end
  end



end

