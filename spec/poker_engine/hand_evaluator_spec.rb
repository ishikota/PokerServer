require 'rails_helper'

RSpec.describe HandEvaluator do

  let(:evaluator) { HandEvaluator.new }

  describe "evaluates hand strength" do
    let(:community) { [] }
    let(:hole) { [] }

    context "HighCard" do
      before {
        community << card(Card::CLUB, 3)
        community << card(Card::CLUB, 7)
        community << card(Card::CLUB, 10)
        community << card(Card::DIAMOND, 5)
        community << card(Card::DIAMOND, 6)
        hole << card(Card::CLUB, 9)
        hole << card(Card::DIAMOND, 2)
      }

      it "should evaluate high card with hokecards 9 and 2" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::HIGHCARD
        expect(evaluator.mask_high_rank(bit)).to eq 9
        expect(evaluator.mask_low_rank(bit)).to eq 2
      end
    end

    context "OnePair" do
      before {
        community << card(Card::CLUB, 3)
        community << card(Card::CLUB, 7)
        community << card(Card::CLUB, 10)
        community << card(Card::DIAMOND, 5)
        community << card(Card::DIAMOND, 6)
        hole << card(Card::CLUB, 9)
        hole << card(Card::DIAMOND, 3)
      }

      it "should evaluate as one pair of 3" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::ONEPAIR
        expect(evaluator.mask_high_rank(bit)).to eq 3
        expect(evaluator.mask_low_rank(bit)).to eq 0
      end
    end

  end


  private

    def card(suit, rank)
      Card.new(suit, rank)
    end

end

