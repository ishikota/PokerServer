require 'rails_helper'

RSpec.describe ActionChecker do

  let(:action_checker) { ActionChecker.new }

  context "when no action is done before" do

    let(:players) do
      [1,2].inject([]) { |ary, i|
        player = double("player#{i}")
        allow(player).to receive(:action_histories).and_return []
        allow(player).to receive(:stack).and_return 100
        allow(player).to receive(:paid_sum).and_return 0
        ary << player
      }
    end

    describe "CALL $0 (CHECK)" do

      it "should be legal" do
        expect(action_checker.illegal?(players, 0, 'call', 0)).to be_falsy
      end

      specify "need amount for action is $0" do
        expect(need_amount(players[0], 0)).to eq 0
        expect(need_amount(players[1], 0)).to eq 0
      end
    end

    describe "CALL $10" do

      it "should be illegal" do
        expect(action_checker.illegal?(players, 0, 'call', 10)).to be_truthy
      end

    end

    describe "RAISE $1" do

      it "should be illegal because bet amount is smaller than DEFAULT minimum raise amount" do
        expect(action_checker.illegal?(players, 0, 'raise', 1)).to be_truthy
      end
    end

    describe "RAISE $5" do

      it "should be legal" do
        expect(action_checker.illegal?(players, 0, 'raise', 5)).to be_falsy
      end

      specify "need amount for action is $10" do
        expect(need_amount(players[0], 5)).to eq 5
        expect(need_amount(players[1], 5)).to eq 5
      end
    end
  end


  context "when agree amount = $10, minimum bet = $15" do
    let(:player1) do
      player1 = double("small blind")
      allow(player1).to receive(:action_histories)
          .and_return(create_history('RAISE', 5, 5, 5))
      allow(player1).to receive(:stack).and_return 95
      allow(player1).to receive(:paid_sum).and_return 5
      player1
    end

    let(:player2) do
      player2 = double("big blind")
      allow(player2).to receive(:action_histories)
          .and_return(create_history('RAISE', 10, 10, 5))
      allow(player2).to receive(:stack).and_return 90
      allow(player1).to receive(:paid_sum).and_return 10
      player2
    end

    let(:players) { [ player1, player2 ] }

    describe "FOLD" do

      it "shold be legal" do
        expect(action_checker.illegal?(players, 0, 'fold')).to be_falsy
      end

    end

    describe "CALL $10" do

      it "should be legal" do
        expect(action_checker.illegal?(players, 0, 'call', 10)).to be_falsy
      end

      specify "need amount for action" do
        expect(need_amount(player1, 10)).to eq 5
        expect(need_amount(player2, 10)).to eq 0
      end
    end

    describe "CALL $5" do

      it "should be illegal" do
        expect(action_checker.illegal?(players, 0, 'call', 5)).to be_truthy
      end

    end

    describe "CALL $15" do

      it "should be illegal" do
        expect(action_checker.illegal?(players, 0, 'call', 15)).to be_truthy
      end

    end

    describe "RAISE $10" do

      it "should be illegal" do
        expect(action_checker.illegal?(players, 0, 'raise', 10)).to be_truthy
      end

    end

    describe "RAISE $15" do

      it "should return legal" do
        expect(action_checker.illegal?(players, 0, 'raise', 15)).to be_falsy
      end

      specify "need amount for action" do
        expect(need_amount(player1, 15)).to eq 10
        expect(need_amount(player2, 15)).to eq 5
      end
    end

    context "when player does not have enough money" do
      before {
        allow(player1).to receive(:stack).and_return 7
      }

      describe "and declare CALL $10" do

        it "shoulld be illegal" do
          expect(action_checker.illegal?(players, 0, 'call', 10)).to be_truthy
        end
      end

      describe "and declare RAISE $15" do

        it "should illegal" do
          expect(action_checker.illegal?(players, 0, 'raise', 15)).to be_truthy
        end

      end

    end

  end

  describe "allin?" do

    context "when passed action is allin" do

      it "should return true"

    end

    context "when passed action is not allin" do

      it "should return false"

    end

  end


  private

    def need_amount(player, amount)
      action_checker.need_amount_for_action(player, amount)
    end

    def create_history(action, amount=nil, paid=nil, add_amount=nil)
      history = { "action" => action }
      history.merge!( { "amount" => amount } ) unless amount.nil?
      history.merge!( { "paid" => paid } ) unless paid.nil?
      history.merge!( { "add_amount" => add_amount } ) unless add_amount.nil?
    end

end

