require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("dealer.finish_round") }
  let(:broadcaster) { double("broadcaster") }
  let(:round_manager) { RoundManager.new(broadcaster, finish_callback) }

  describe "#start_new_round" do
    let(:table) { double("table") }
    let(:seats) { double("seats") }

    before {
      allow(seats).to receive(:collect_bet)
      allow(seats).to receive(:size).and_return(2)
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:dealer_btn).and_return(0)
      allow(broadcaster).to receive(:ask)
    }

    it "should collect blind" do
      small_blind = 5  #TODO read blind amount from somewhare
      expect(seats).to receive(:collect_bet).with(0, small_blind)
      expect(seats).to receive(:collect_bet).with(1, small_blind * 2)

      round_manager.start_new_round(table)
    end

  end

  describe "#apply_action" do

    let(:table) { double("table") }
    let(:pot) { double("pot") }
    let(:seats) { double("seats") }

    before {
      allow(pot).to receive(:add_chip)
      allow(seats).to receive(:collect_bet)
      allow(seats).to receive(:count_active_player)
      allow(seats).to receive(:size).and_return(2)
      allow(table).to receive(:pot).and_return(pot)
      allow(table).to receive(:seats).and_return(seats)
      allow(broadcaster).to receive(:ask)
    }

    describe "apply passed action to table" do

      context "when passed action is CALL" do

        it "should execute chip transaction" do
          expect(seats).to receive(:collect_bet).with(0, 5)
          expect(pot).to receive(:add_chip).with(5)

          round_manager.apply_action(table, 'call', 5)
        end

        it "should increment agree_num" do
          expect {
            round_manager.apply_action(table, 'call', 5)
          }.to change { round_manager.agree_num }.by(1)
        end
      end

      context "when passed action is FOLD" do
        before {
          allow(seats).to receive(:deactivate)
          allow(seats).to receive(:count_active_player)
        }

        it "should deactivate player" do
          expect(seats).to receive(:deactivate).with(0)

          round_manager.apply_action(table, 'fold', nil)
        end
      end

      context "when passed action is RAISE" do

        it "should execute chip transaction" do
          expect(seats).to receive(:collect_bet).with(0, 5)
          expect(pot).to receive(:add_chip).with(5)

          round_manager.apply_action(table, 'raise', 5)
        end

        it "should reset agree_num" do
          round_manager.apply_action(table, 'raise', 5)
          expect(round_manager.agree_num).to eq 1
        end
      end

      context "when passed action is illegal" do

        it "should accept the action as fold"

      end

    end


    context "when all players have agreed" do

      before {
        table.as_null_object
        round_manager.increment_agree_num
      }

      it "should start next street" do
        expect {
          round_manager.apply_action(table, 'call', 5)
        }.to change {
          round_manager.street
        }.by(1)
      end

    end

    context "when not agreed player exists" do

      it "should ask action to him" do
        expect(broadcaster).to receive(:ask).with(1, "TODO")

        expect {
          round_manager.apply_action(table, 'call', nil)
        }.to change { round_manager.next_player }.by(1)
      end

    end

  end

  describe "#preflop" do
    let(:table) { double("table") }
    let(:seats) { double("seats") }

    before {
      allow(seats).to receive(:size).and_return(3)
      allow(table).to receive(:seats).and_return(seats)
    }

    it "should ask action to player who sits next to blind player" do
      expect(broadcaster).to receive(:ask).with(2, anything)

      round_manager.start_street(RoundManager::PREFLOP, table)
      expect(round_manager.next_player).to eq 2
    end

  end

  describe "#flop" do
    let(:table) { double("table") }
    let(:deck) { double("deck") }
    let(:community_card) { double("community cards") }

    before {
      allow(deck).to receive(:draw_cards).and_return(["card1", "card2", "card3"])
      allow(table).to receive(:deck).and_return(deck)
      allow(table).to receive(:community_card).and_return(community_card)
      allow(broadcaster).to receive(:ask)
      allow(community_card).to receive(:add)
    }

    it "should add three commnity card" do
      expect(community_card).to receive(:add).with("card1")
      expect(community_card).to receive(:add).with("card2")
      expect(community_card).to receive(:add).with("card3")

      round_manager.start_street(RoundManager::FLOP, table)
    end

    it "should ask action to player who has dealer button"  do
      expect(broadcaster).to receive(:ask).with(0, anything)

      round_manager.start_street(RoundManager::FLOP, table)
      expect(round_manager.next_player).to eq 0
    end

  end

  describe "#turn" do
    let(:table) { double("table") }
    let(:deck) { double("deck") }
    let(:community_card) { double("community cards") }

    before {
      allow(deck).to receive(:draw_card).and_return("card1")
      allow(table).to receive(:deck).and_return(deck)
      allow(table).to receive(:community_card).and_return(community_card)
      allow(broadcaster).to receive(:ask)
      allow(community_card).to receive(:add)
    }

    it "should add a community card" do
      expect(community_card).to receive(:add).with("card1")

      round_manager.start_street(RoundManager::TURN, table)
    end

    it "should ask action to player who has dealer button" do
      expect(broadcaster).to receive(:ask).with(0, anything)

      round_manager.start_street(RoundManager::TURN, table)
      expect(round_manager.next_player).to eq 0
    end

  end

  describe "#river" do
    let(:table) { double("table") }
    let(:deck) { double("deck") }
    let(:community_card) { double("community cards") }

    before {
      allow(deck).to receive(:draw_card).and_return("card1")
      allow(table).to receive(:deck).and_return(deck)
      allow(table).to receive(:community_card).and_return(community_card)
      allow(broadcaster).to receive(:ask)
      allow(community_card).to receive(:add)
    }

    it "should add a community card" do
      expect(community_card).to receive(:add).with("card1")

      round_manager.start_street(RoundManager::RIVER, table)
    end

    it "should ask action to player who has dealer button" do
      expect(broadcaster).to receive(:ask).with(0, anything)

      round_manager.start_street(RoundManager::RIVER, table)
      expect(round_manager.next_player).to eq 0
    end

  end

  describe "#showoff" do

    it "should call dealer's callback with game result"

  end

  describe "#shift_next_player" do
    let(:seats) { double("seats") }
    before {
      allow(seats).to receive(:size).and_return(2)
      allow(seats).to receive(:count_active_player)
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
      allow(seats).to receive(:count_active_player)
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

