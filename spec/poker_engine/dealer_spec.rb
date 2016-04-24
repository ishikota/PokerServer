require 'rails_helper'

RSpec.describe "Dealer" do

  describe "#setup_game" do

    it "should define player seats position"

  end

  describe "#start_game" do

    it "should setup and start first round"

  end

  describe "#setup_round" do

    it "should increment round count"

    it "should shuffule deck"

    it "should deal cards to player"

    it "should collect blinds"

  end

  describe "#start_round" do

    it "should broadcast start of the round for everyone in the room"

    it "should notify start to round manager"

  end

  describe "#resume_round" do

    it "should pass received action to round_manager and resume game"

  end

  describe "#finish_round" do

    it "should notify game result"

    it "should call teardown_round"

  end

  describe "#teardown_round" do

    describe "prepare for next round" do

      it "should shift dealer button position"

      it "should clear pot chip"

      it "should clear board card"

      it "should shuffule deck"

      it "should get folded or allin players back"

    end

    context "when last game was not final round" do

      it "should start to setup next round"

      it "should shift dealer button position"

    end

    context "when last game was final round" do

      it "should teardown the game"

    end

    context "when winner is decided" do

      it "should teardown the game"

    end

  end

  describe "#teardown_game" do

    it "should send game result and say goodbye"

  end

end

