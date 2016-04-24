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

end

