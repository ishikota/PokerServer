require 'rails_helper'

RSpec.describe Deck do

  let(:deck) { Deck.new }

  describe "#draw_card" do

    it "should return a card and remove it from deck" do
      card = deck.draw_card
      expect(card.to_s).to eq 'SK'
      expect(deck.size).to eq 51
    end
  end

  describe "#draw_cards" do

    it "should return cards and remove them from deck" do
      cards = deck.draw_cards(3)
      expect(cards[2].to_s).to eq 'SJ'
      expect(deck.size).to eq 49
    end
  end

  describe "restore" do

    before {
      deck.draw_cards(5)
    }

    it "should restore 52 cards to deck" do
      expect { deck.restore }.to change { deck.size }.to 52
    end
  end

  describe "cheat mode" do
    let(:cheat_deck) { Deck.new(cheat=true, cheat_cards=cards) }
    let(:cards) {
      [Card.new(Card::CLUB, 2), Card.new(Card::SPADE, 3), Card.new(Card::CLUB, 4) ]
    }

    it "should draw passed card" do
      expect(cheat_deck.draw_cards(3)).to eq cards
    end

    describe "restore" do

      it "should restore cheat deck" do
        cheat_deck.draw_cards(3)
        expect { cheat_deck.restore }.to change { cheat_deck.size }.to cards.size
        expect(cheat_deck.draw_cards(3)).to eq cards
      end
    end

  end

end

