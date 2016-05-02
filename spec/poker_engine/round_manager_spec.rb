require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("dealer.finish_round") }
  let(:broadcaster) { double("broadcaster") }
  let(:game_evaluator) { double("game evaluator") }
  let(:round_manager) { RoundManager.new(broadcaster, finish_callback, game_evaluator) }

  describe "#start_new_round" do
    let(:table) { double("table") }
    let(:deck) { deck_with_cards }
    let(:seats) { seat_with_active_players }

    before {
      allow(seats).to receive(:collect_bet)
      allow(seats).to receive(:size).and_return(2)
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:dealer_btn).and_return(0)
      allow(table).to receive(:deck).and_return(deck)
      allow(broadcaster).to receive(:ask)
      allow(broadcaster).to receive(:notification)
      for player in seats.players
        allow(player).to receive(:add_holecard)
      end
    }

    it "should collect blind" do
      small_blind = 5  #TODO read blind amount from somewhare
      expect(seats).to receive(:collect_bet).with(0, small_blind)
      expect(seats).to receive(:collect_bet).with(1, small_blind * 2)

      round_manager.start_new_round(table)
    end

    it "should deal hole card to players" do
      expect(seats.players[0]).to receive(:add_holecard).with([anything, anything])
      expect(seats.players[1]).to receive(:add_holecard).with([anything, anything])
      expect(seats.players[2]).to receive(:add_holecard).with([anything, anything])

      round_manager.start_new_round(table)
    end

  end

  describe "#apply_action" do

    let(:table) { double("table") }
    let(:pot) { double("pot") }
    let(:seats) { seat_with_active_players }
    let(:action_checker) { double("action checker") }

    before {
      allow(pot).to receive(:add_chip)
      allow(seats).to receive(:collect_bet)
      allow(seats).to receive(:count_active_player)
      allow(seats).to receive(:size).and_return(2)
      allow(table).to receive(:pot).and_return(pot)
      allow(table).to receive(:seats).and_return(seats)
      allow(broadcaster).to receive(:ask)
      allow(action_checker).to receive(:illegal?).and_return false
    }

    describe "apply passed action to table" do

      context "when passed action is CALL" do

        it "should execute chip transaction" do
          expect(seats).to receive(:collect_bet).with(0, 5)
          expect(pot).to receive(:add_chip).with(5)

          round_manager.apply_action(table, 'call', 5, action_checker)
        end

        it "should increment agree_num" do
          expect {
            round_manager.apply_action(table, 'call', 5, action_checker)
          }.to change { round_manager.agree_num }.by(1)
        end

        it "should update player's pay_info" do
          expect(seats.players[0]).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::CALL, 5)

          round_manager.apply_action(table, 'call', 5, action_checker)
        end
      end

      context "when passed action is FOLD" do
        before {
          allow(seats).to receive(:deactivate)
          allow(seats).to receive(:count_active_player)
        }

        it "should deactivate player" do
          expect(seats).to receive(:deactivate).with(0)

          round_manager.apply_action(table, 'fold', nil, action_checker)
        end

        it "should update player's pay_info" do
          expect(seats.players[0]).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::FOLD)

          round_manager.apply_action(table, 'fold', nil, action_checker)
        end
      end

      context "when passed action is RAISE" do

        it "should execute chip transaction" do
          expect(seats).to receive(:collect_bet).with(0, 5)
          expect(pot).to receive(:add_chip).with(5)

          round_manager.apply_action(table, 'raise', 5, action_checker)
        end

        it "should reset agree_num" do
          round_manager.apply_action(table, 'raise', 5, action_checker)
          expect(round_manager.agree_num).to eq 1
        end

        it "should update player's pay_info" do
          expect(seats.players[0]).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::RAISE, 5)

          round_manager.apply_action(table, 'raise', 5, action_checker)
        end
      end

      context "when passed action is illegal" do
        before {
          allow(action_checker).to receive(:illegal?).and_return(true)
        }

        it "should accept the action as fold" do
          expect(seats).to receive(:deactivate).with(0)
          expect(seats.players[0]).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::FOLD)

          round_manager.apply_action(table, 'raise', 100, action_checker)
          expect(round_manager.agree_num).to eq 0
        end

      end

    end

    context "when not agreed player exists" do

      it "should ask action to him" do
        expect(broadcaster).to receive(:ask).with(1, "TODO")

        expect {
          round_manager.apply_action(table, 'call', nil, action_checker)
        }.to change { round_manager.next_player }.by(1)
      end

    end

  end

  describe "#preflop" do
    let(:table) { double("table") }
    let(:seats) { seat_with_active_players }

    before {
      allow(broadcaster).to receive(:notification)
      allow(seats).to receive(:size).and_return(3)
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:dealer_btn).and_return(0)
    }

    it "should ask action to player who sits next to blind player" do
      expect(broadcaster).to receive(:ask).with(2, anything)

      round_manager.start_street(RoundManager::PREFLOP, table)
      expect(round_manager.next_player).to eq 2
    end

  end

  describe "#flop" do
    let(:table) { double("table") }
    let(:seats) { seat_with_active_players }
    let(:deck) { double("deck") }
    let(:community_card) { double("community cards") }

    before {
      allow(broadcaster).to receive(:notification)
      allow(deck).to receive(:draw_cards).and_return(["card1", "card2", "card3"])
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:deck).and_return(deck)
      allow(table).to receive(:community_card).and_return(community_card)
      allow(table).to receive(:dealer_btn).and_return(0)
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
    let(:seats) { seat_with_active_players }
    let(:deck) { double("deck") }
    let(:community_card) { double("community cards") }

    before {
      allow(broadcaster).to receive(:notification)
      allow(deck).to receive(:draw_card).and_return("card1")
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:deck).and_return(deck)
      allow(table).to receive(:community_card).and_return(community_card)
      allow(table).to receive(:dealer_btn).and_return(0)
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
    let(:seats) { seat_with_active_players }
    let(:deck) { double("deck") }
    let(:community_card) { double("community cards") }

    before {
      allow(broadcaster).to receive(:notification)
      allow(deck).to receive(:draw_card).and_return("card1")
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:deck).and_return(deck)
      allow(table).to receive(:community_card).and_return(community_card)
      allow(table).to receive(:dealer_btn).and_return(0)
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

  describe "#showdown" do
    let(:table) { double("table") }
    let(:seats) { seat_with_active_players }

    before {
      allow(broadcaster).to receive(:notification)
      allow(table).to receive(:dealer_btn).and_return(0)
      allow(table).to receive(:seats).and_return(seats)
      allow(table).to receive(:reset)
    }

    it "should clear table state like before the round" do
      allow(finish_callback).to receive(:call)
      allow(game_evaluator).to receive(:judge)
      expect(table).to receive(:reset)

      round_manager.start_street(RoundManager::SHOWDOWN, table)
    end

    it "should call dealer's callback with game result" do
      expect(finish_callback).to receive(:call).with("dummy player", "accounting info")
      allow(game_evaluator).to receive(:judge)
          .and_return(["dummy player", "accounting info"])

      round_manager.start_street(RoundManager::SHOWDOWN, table)
    end

  end

  describe "#shift_next_player" do
    let(:seats) { double("seats") }
    let(:players) do
      (1..3).inject([]) { |acc, i| acc << double("player#{i}") }
    end

    before {
      allow(seats).to receive(:size).and_return(3)
      allow(seats).to receive(:count_active_player)
      allow(seats).to receive(:players).and_return(players)
      for player in players
        allow(player).to receive(:active?).and_return(true)
      end
    }

    context "when next player is active" do

      it "should shift next player to second player" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 1
      end

    end

    context "when next player is not active" do

      before {
        allow(players[1]).to receive(:active?).and_return(false)
      }

      it "should skip the person" do
        round_manager.shift_next_player(seats)
        expect(round_manager.next_player).to eq 2
      end

    end

    describe "cycle ask order" do

      before {
        round_manager.shift_next_player(seats)
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
      allow(seats).to receive(:count_active_player).and_return(2)
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


  private

    def seat_with_active_players
      players =  (1..3).inject([]) do |acc, i|
        player = double("player#{i}")
        allow(player).to receive(:active?).and_return(true)
        allow(player).to receive(:init_action_histories)
        allow(player).to receive(:init_pay_info)
        allow(player).to receive(:add_action_history)
        acc << player
      end

      seats = double("seats")
      allow(seats).to receive(:players).and_return(players)
      return seats
    end

    def deck_with_cards
      deck = double("deck")
      card = double("card")
      allow(card).to receive(:is_a?).with(Card).and_return(true)
      allow(deck).to receive(:draw_cards).and_return([card, card])
      deck
    end


end

