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

    context "TwoPair" do
      before {
        community << card(Card::CLUB, 7)
        community << card(Card::CLUB, 9)
        community << card(Card::DIAMOND, 3)
        community << card(Card::DIAMOND, 2)
        community << card(Card::DIAMOND, 5)
        hole << card(Card::CLUB, 9)
        hole << card(Card::DIAMOND, 3)
      }

      it "should evaluate as two pair of 9 and 3" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::TWOPAIR
        expect(evaluator.mask_high_rank(bit)).to eq 9
        expect(evaluator.mask_low_rank(bit)).to eq 3
      end
    end

    context "ThreeCard" do
      before {
        community << card(Card::CLUB, 3)
        community << card(Card::CLUB, 7)
        community << card(Card::DIAMOND, 3)
        community << card(Card::DIAMOND, 5)
        community << card(Card::DIAMOND, 6)
        hole << card(Card::CLUB, 9)
        hole << card(Card::DIAMOND, 3)
      }

      it "should evaluate as trhee card of 3" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::THREECARD
        expect(evaluator.mask_high_rank(bit)).to eq 3
        expect(evaluator.mask_low_rank(bit)).to eq 0
      end
    end

    context "Straight" do
      before {
        community << card(Card::CLUB, 3)
        community << card(Card::CLUB, 7)
        community << card(Card::DIAMOND, 2)
        community << card(Card::DIAMOND, 5)
        community << card(Card::DIAMOND, 6)
        hole << card(Card::CLUB, 4)
        hole << card(Card::DIAMOND, 5)
      }

      it "should evaluate as straight" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::STRAIGHT
        expect(evaluator.mask_high_rank(bit)).to eq 3
        expect(evaluator.mask_low_rank(bit)).to eq 0
      end
    end

    context "Flash" do
      before {
        community << card(Card::CLUB, 7)
        community << card(Card::DIAMOND, 2)
        community << card(Card::DIAMOND, 3)
        community << card(Card::DIAMOND, 5)
        community << card(Card::DIAMOND, 6)
        hole << card(Card::CLUB, 4)
        hole << card(Card::DIAMOND, 5)
      }

      it "should evaluate as trhee flash" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::FLASH
        expect(evaluator.mask_high_rank(bit)).to eq 6
        expect(evaluator.mask_low_rank(bit)).to eq 0
      end
    end

    context "Fullhouse" do
      before {
        community << card(Card::CLUB, 4)
        community << card(Card::DIAMOND, 2)
        community << card(Card::DIAMOND, 4)
        community << card(Card::DIAMOND, 5)
        community << card(Card::DIAMOND, 6)
        hole << card(Card::CLUB, 4)
        hole << card(Card::DIAMOND, 5)
      }

      it "should evaluate as fullhouse of three 4 and two 5" do
        bit = evaluator.eval_hand(hole, community)
        expect(evaluator.mask_strength(bit)).to eq HandEvaluator::FULLHOUSE
        expect(evaluator.mask_high_rank(bit)).to eq 4
        expect(evaluator.mask_low_rank(bit)).to eq 5
      end
    end


  end

  private

    def card(suit, rank)
      Card.new(suit, rank)
    end

end

