require 'rails_helper'

RSpec.describe Card do

  describe "#to_s" do

    it "should return rank and suit of the card" do
      expect(Card.new(Card::CLUB, 1).to_s).to eq "CA"
      expect(Card.new(Card::CLUB, 2).to_s).to eq "C2"
      expect(Card.new(Card::HEART, 10).to_s).to eq "HT"
      expect(Card.new(Card::SPADE, 11).to_s).to eq "SJ"
      expect(Card.new(Card::DIAMOND, 12).to_s).to eq "DQ"
      expect(Card.new(Card::DIAMOND, 13).to_s).to eq "DK"
    end
  end

  describe "#to_id" do

    it "should return the id of the card" do
      expect(Card.new(Card::HEART, 3).to_id).to eq 29
      expect(Card.new(Card::SPADE, 1).to_id).to eq 40
    end
  end

  describe "#initialize" do

    it "should initialize from suit and rank" do
      card = Card.new(Card::CLUB, 1)
      expect(card.suit).to eq Card::CLUB
      expect(card.rank).to eq 14
    end

    it "should initialize from id" do
      card = Card.from_id(1)
      expect(card.suit).to eq Card::CLUB
      expect(card.rank).to eq 1

      card = Card.from_id(29)
      expect(card.suit).to eq Card::HEART
      expect(card.rank).to eq 3

      card = Card.from_id(40)
      expect(card.suit).to eq Card::SPADE
      expect(card.rank).to eq 1
    end

  end

end

