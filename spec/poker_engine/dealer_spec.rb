require 'rails_helper'

RSpec.describe "Dealer" do

  let(:dealer) { Dealer.new(components_holder) }
  let(:config) { double("config") }
  let(:table) { double("table") }
  let(:seats) { double("seats") }
  let(:broadcaster) { double("broadcaster") }
  let(:round_manager) { double("round manager") }
  let(:action_checker) { double("action checker") }
  let(:player_maker) { double("player_maker") }

  let(:components_holder) do
    {
      broadcaster: broadcaster,
      config: config,
      table: table,
      round_manager: round_manager,
      action_checker: action_checker,
      player_maker: player_maker
    }
  end


  before {
    allow(table).to receive(:seats).and_return(seats)
  }

  describe "#start_game" do

    let(:seat) { double("seat") }
    let(:player1) { double("player1") }
    let(:player2) { double("player2") }

    before {
      allow(table).to receive(:seat).and_return seat
      allow(seats).to receive(:sitdown)
      allow(config).to receive(:initial_stack).and_return(100)
      allow(player_maker).to receive(:create).and_return(player1, player2)
      allow(round_manager).to receive(:start_new_round)
      allow(broadcaster).to receive(:notification)
    }

    it "should define player seats position" do
      expect(seats).to receive(:sitdown).with(player1)
      expect(seats).to receive(:sitdown).with(player2)
      dealer.start_game(["dummy", "playerinfo"])
    end

    it "should send game information to players" do
      expect(broadcaster).to receive(:notification).with("TODO game info")
      dealer.start_game(["dummy", "playerinfo"])
    end

    it "should start first round" do
      expect(round_manager).to receive(:start_new_round).with(table)
      dealer.start_game(["dummy", "playerinfo"])
    end

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

