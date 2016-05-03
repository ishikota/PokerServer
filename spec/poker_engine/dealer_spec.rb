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
    allow(round_manager).to receive(:set_finish_callback)
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

  describe "#receive_data" do

    it "should pass received action to round_manager and resume game" do
      expect(round_manager).to receive(:apply_action)
          .with(table, "call", 10, action_checker)

      dealer.receive_data(0, { "action" => "call", "bet_amount" => 10 })
    end

  end

  describe "#finish_round" do
    let(:player1) { double("player1") }
    let(:player2) { double("player2") }
    let(:winners) { [player1] }
    let(:accounting_info) { { 1 => 20 } }
    let(:community_card) { double("community card") }

    before {
      allow(table).to receive(:community_card).and_return(community_card)
      allow(table).to receive(:shift_dealer_btn)
      allow(broadcaster).to receive(:notification)
      allow(config).to receive(:max_round).and_return(10)
    }

    it "should notify game result" do
      allow(table).to receive(:shift_dealer_btn)
      allow(round_manager).to receive(:start_new_round)
      expect(broadcaster).to receive(:notification).with("TODO game result")

      dealer.finish_round_callback.call(winners, accounting_info)
    end

    describe "#teardown_round" do

      context "when last game was not final round" do

        it "should shift dealer button position" do
          allow(round_manager).to receive(:start_new_round)
          expect(table).to receive(:shift_dealer_btn)

          dealer.finish_round_callback.call(winners, accounting_info)
        end

        it "should start next round" do
          expect(round_manager).to receive(:start_new_round)

          dealer.finish_round_callback.call(winners, accounting_info)
        end
      end

      context "when last game was final round" do

        before {
          allow(config).to receive(:max_round).and_return(0)
        }

        it "should not start the next game" do
          expect(round_manager).not_to receive(:start_new_round)

          dealer.finish_round_callback.call(winners, accounting_info)
        end


        it "should teardown the game and say goodbye to players" do
          expect(broadcaster).to receive(:notification).with("TODO goodbye")

          dealer.finish_round_callback.call(winners, accounting_info)
        end
      end

      context "when winner is decided" do

        it "should teardown the game"

      end
    end

  end

end

