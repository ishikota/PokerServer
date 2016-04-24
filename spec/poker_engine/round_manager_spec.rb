require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("dealer.finish_round") }
  let(:broadcaster) { double("broadcaster") }
  let(:round_manager) { RoundManager.new(broadcaster, finish_callback) }

  describe "#start_new_round" do

    it "should start preflop"

  end

  describe "#apply_action" do

    describe "apply passed action to table" do

      context "when passed action is illegal" do

        it "should accept the action as fold"

      end

      it "should execute chip transaction"

      it "should shift next player"

    end


    context "when all players have agreed" do

      it "should start next street"

    end

    context "when not agreed player exists" do

      it "should ask action to him"

    end

  end

  describe "#preflop" do

    it "should ask action to player who sits next to blind player"

  end

  describe "#flop" do

    it "should add three commnity card"

    it "should ask action to player who has dealer button"

  end

  describe "#turn" do

    it "should add a community card"

    it "should ask action to player who has dealer button"

  end

  describe "#river" do

    it "should add a community card"

    it "should ask action to player who has dealer button"

  end

  describe "#showoff" do

    it "should call dealer's callback with game result"

  end

  describe "#shift_next_player" do
    let(:seats) { double("seats") }
    before {
      allow(seats).to receive(:size).and_return(2)
    }

    context "when next player is active" do

      it "should shift next player to second player" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 1
      end

    end

    context "when next player is not active" do

      it "should skip the person"

    end

    describe "cycle ask order" do

      before {
        round_manager.shift_next_player(seats)
      }

      it "should shift next player to first player" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 0
      end

    end
  end

  describe "#everyone_agree?" do
    let(:seats) { double("seats") }

    before {
      allow(seats).to receive(:size).and_return(2)
    }

    context "when a player does not agree" do

      it "should return false" do
        expect(round_manager.everyone_agree?(seats)).to be_falsy
      end

    end

    context "when everyone agreed" do

      before {
        round_manager.increment_agree_num
        round_manager.increment_agree_num
      }

      it "should return true" do
        expect(round_manager.everyone_agree?(seats)).to be_truthy
      end
    end
  end


end

