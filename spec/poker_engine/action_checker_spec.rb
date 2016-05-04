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
    let(:player1) { create_blind_player(small_blind=true) }
    let(:player2) { create_blind_player(small_blind=false) }
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

        it "shoulld be legal because he already paid $5" do
          expect(action_checker.illegal?(players, 0, 'call', 10)).to be_falsy
        end
      end

      describe "and declare RAISE $15" do

        it "should illegal" do
          expect(action_checker.illegal?(players, 0, 'raise', 15)).to be_truthy
        end
      end

    end

  end

  describe "allin check" do

    let(:sb_player) { create_blind_player(small_blind=true) }
    let(:bb_player) { create_blind_player(small_blind=false) }
    let(:players) { [ sb_player, bb_player ] }

    context "when passed action is allin" do

      describe "small blind allin by RAISE $100" do
        it "should be legal" do
          expect(action_checker.illegal?(players, 0, 'raise', 100)).to be_falsy
        end
      end

      describe "small blind allin by RAISE $100 and big blind CALL it by allin" do

        before {
          history = [] << create_history('RAISE', 5, 5, 5) << create_history('RAISE', 100, 95, 90)
          allow(sb_player).to receive(:action_histories).and_return(history)
        }

        it "should be legal" do
          expect(action_checker.illegal?(players, 1, 'call', 100)).to be_falsy
        end

        describe "boundary value test" do

          before { allow(bb_player).to receive(:stack).and_return 89 }

          it "should be illegal" do
            expect(action_checker.illegal?(players, 1, 'call', 100)).to be_truthy
          end
        end

      end
    end

    context "when passed action is not allin" do

      it "should return false"

    end

  end

  describe "allin?" do

    let(:player) do
      player = double("player")
      allow(player).to receive(:stack).and_return(100)
      player
    end

    it "should work" do
      expect(action_checker.allin?(player, 99)).to be_falsy
      expect(action_checker.allin?(player, 100)).to be_truthy
      expect(action_checker.allin?(player, 101)).to be_truthy
    end

  end


  private

    def need_amount(player, amount)
      action_checker.need_amount_for_action(player, amount)
    end

    def create_blind_player(small_blind=true)
      name = small_blind ? "small blind" : "big blind"
      blind_amount = small_blind ? 5 : 10

      player = double(name)
      allow(player).to receive(:action_histories)
          .and_return(create_history('RAISE', blind_amount, blind_amount, 5))
      allow(player).to receive(:stack).and_return 100 - blind_amount
      allow(player).to receive(:paid_sum).and_return blind_amount
      player
    end

    def create_history(action, amount=nil, paid=nil, add_amount=nil)
      history = { "action" => action }
      history.merge!( { "amount" => amount } ) unless amount.nil?
      history.merge!( { "paid" => paid } ) unless paid.nil?
      history.merge!( { "add_amount" => add_amount } ) unless add_amount.nil?
    end

end

