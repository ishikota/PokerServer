require 'rails_helper'

RSpec.describe ActionChecker do

  let(:action_checker) { ActionChecker.new }

  context "when no action is done before" do
    let(:player1) { create_clean_player_with_stack("player1", 100) }
    let(:player2) { create_clean_player_with_stack("player2", 100) }
    let(:players) { [ player1, player2 ] }

    describe "CALL $0 (CHECK)" do

      it "should be legal" do
        expect(action_checker.illegal?(players, 0, 'call', 0)).to be_falsy
      end

      specify "need amount for action is $0" do
        expect(need_amount(player1, 0)).to eq 0
        expect(need_amount(player2, 0)).to eq 0
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
        expect(need_amount(player1, 5)).to eq 5
        expect(need_amount(player2, 5)).to eq 5
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

  end

  describe "allin?" do

    let(:player) { create_clean_player_with_stack("player", 100) }

    context "passed action is CALL" do

      it "should judge if allin or not" do
        expect(action_checker.allin?(player, 'call', 99)).to be_falsy
        expect(action_checker.allin?(player, 'call', 100)).to be_truthy
        expect(action_checker.allin?(player, 'call', 101)).to be_truthy
      end
    end

    context "passed action is ALLIN RAISE" do

      it "should judge if allin or not" do
        expect(action_checker.allin?(player, 'raise',  99)).to be_falsy
        expect(action_checker.allin?(player, 'raise', 100)).to be_truthy
        expect(action_checker.allin?(player, 'raise', 101)).to be_falsy
      end
    end

    context "when passed action is FOLD" do

      it "should return false" do
        expect(action_checker.allin?(player, 'fold', 0)).to be_falsy
      end
    end

  end

  describe "correct_action" do
    let(:player1) { create_clean_player_with_stack("player1", 100) }
    let(:player2) { create_clean_player_with_stack("player2", 100) }
    let(:players) { [ player1, player2 ] }

    context "when passed ALLIN CALL" do

      before {
        history = [] << create_history("RAISE", 50, 50, 50)
        allow(player1).to receive(:action_histories).and_return history
        allow(player2).to receive(:stack).and_return 30
      }

      it "should correct bet_amount to his stack amount" do
        action, bet_amount = action_checker.correct_action(players, 1, 'call', 50)
        expect(action).to eq 'call'
        expect(bet_amount).to eq 30
      end
    end

    context "when passed ALLIN RAISE" do

      it "should correct bet_amount to his stack" do
        action, bet_amount = action_checker.correct_action(players, 0, 'raise', 100)
        expect(action).to eq 'raise'
        expect(bet_amount).to eq 100
      end
    end

    context "when passed illegal action" do

      it "should convert the action into fold" do
        action, bet_amount = action_checker.correct_action(players, 0, 'call', 10)
        expect(action).to eq 'fold'
        expect(bet_amount).to eq 0
      end

      it "should convert the action into fold" do
        action, bet_amount = action_checker.correct_action(players, 0, 'raise', 110)
        expect(action).to eq 'fold'
        expect(bet_amount).to eq 0
      end
    end

    describe "when passed legal action" do

      it "should return the action as it is" do
        action, bet_amount = action_checker.correct_action(players, 0, 'call', 0)
        expect(action).to eq 'call'
        expect(bet_amount).to eq 0
      end

      it "should return the action as it is" do
        action, bet_amount = action_checker.correct_action(players, 0, 'raise', 10)
        expect(action).to eq 'raise'
        expect(bet_amount).to eq 10
      end
    end

  end


  private

    def need_amount(player, amount)
      action_checker.need_amount_for_action(player, amount)
    end

    def create_clean_player_with_stack(name, stack_amount)
      player = double(name)
      allow(player).to receive(:stack).and_return(stack_amount)
      allow(player).to receive(:action_histories).and_return []
      allow(player).to receive(:paid_sum).and_return 0
      player
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

