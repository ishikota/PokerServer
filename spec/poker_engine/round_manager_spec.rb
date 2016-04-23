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


end

