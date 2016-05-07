require 'rails_helper'

RSpec.describe RoundManager do

  let(:finish_callback) { double("dealer.finish_round") }
  let(:broadcaster) { double("broadcaster") }
  let(:game_evaluator) { double("game evaluator") }
  let(:message_builder) { double("message_builder") }
  let(:round_manager) { RoundManager.new(broadcaster, game_evaluator, message_builder) }

  before {
    round_manager.set_finish_callback(finish_callback)
    allow(message_builder).to receive(:round_start_message).and_return("round_msg")
    allow(message_builder).to receive(:street_start_message).and_return("street_msg")
    allow(message_builder).to receive(:ask_message).and_return("ask_msg")
    allow(message_builder).to receive(:game_update_message).and_return("update")
  }

  describe "#apply_action" do

    let(:table) { setup_table }
    let(:seats) { table.seats }
    let(:player1) { seats.players[0] }
    let(:player2) { seats.players[1] }
    let(:player3) { seats.players[2] }
    let(:action_checker) { double("action checker") }

    before {
      allow(broadcaster).to receive(:ask)
      allow(broadcaster).to receive(:notification).with("update")
      allow(action_checker).to receive(:illegal?).and_return false
    }

    describe "apply passed action to table" do

      it "should notify update to all players" do
        setup_action_checker(player1, 0, 10)
        expect(broadcaster).to receive(:notification).with("update")

        apply_action(round_manager, table, 'call', 10, action_checker)
      end

      context "when passed action is CALL" do

        describe "chip transation" do

          context "when not yet paid" do

            before { setup_action_checker(player1, 0, 10) }

            it "should pay $10" do
              expect(player1).to receive(:collect_bet).with(10)
              expect(player1.pay_info).to receive(:update_by_pay).with(10)

              apply_action(round_manager, table, 'call', 10, action_checker)
            end
          end

          context "when already paid $5" do

            before { setup_action_checker(player1, 5, 5) }

            it "should pay only $5" do
              expect(player1).to receive(:collect_bet).with(5)
              expect(player1.pay_info).to receive(:update_by_pay).with(5)

              apply_action(round_manager, table, 'call', 10, action_checker)
            end
          end

        end

        it "should increment agree_num" do
          setup_action_checker(player1, 0, 5)
          expect {
            apply_action(round_manager, table, 'call', 5, action_checker)
          }.to change { round_manager.agree_num }.by(1)
        end

        it "should update player's pay_info" do
          setup_action_checker(player1, 0, 5)
          expect(player1).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::CALL, 5)

          apply_action(round_manager, table, 'call', 5, action_checker)
        end
      end

      context "when passed action is FOLD" do
        before {
          allow(seats).to receive(:count_active_player)
          allow(player1.pay_info).to receive(:update_to_fold)
          setup_action_checker(player1, 0, 10)
        }

        it "should deactivate player" do
          expect(player1.pay_info).to receive(:update_to_fold)

          apply_action(round_manager, table, 'fold', nil, action_checker)
        end

        it "should update player's pay_info" do
          expect(player1).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::FOLD)

          apply_action(round_manager, table, 'fold', nil, action_checker)
        end
      end

      context "when passed action is RAISE" do

        describe "chip transaction" do

          context "when not yet paid" do

            it "should pay $10" do
              setup_action_checker(player1, 0, 10)
              expect(player1).to receive(:collect_bet).with(10)
              expect(player1.pay_info).to receive(:update_by_pay).with(10)

              apply_action(round_manager, table, 'raise', 10, action_checker)
            end
          end

          context "when already paid $5" do
            before {
              allow(player1).to receive(:paid_sum).and_return(5)
              setup_action_checker(player1, 5, 5)
            }

            it "shoukd pay only $5" do
              expect(player1).to receive(:collect_bet).with(5)
              expect(player1.pay_info).to receive(:update_by_pay).with(5)

              apply_action(round_manager, table, 'raise', 10, action_checker)
            end
          end

        end

        it "should reset agree_num" do
          setup_action_checker(player1, 0, 5)
          apply_action(round_manager, table, 'raise', 5, action_checker)
          expect(round_manager.agree_num).to eq 1
        end

        it "should update player's pay_info" do
          setup_action_checker(player1, 0, 5)
          expect(player1).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::RAISE, 10, 5)

          apply_action(round_manager, table, 'raise', 10, action_checker)
        end
      end

      context "when passed action is illegal" do
        before {
          setup_action_checker(player1, 0, 100)
          allow(action_checker).to receive(:correct_action).and_return ['fold', 0]
        }

        it "should accept the action as fold" do
          expect(player1.pay_info).to receive(:update_to_fold)
          expect(player1).to receive(:add_action_history)
              .with(PokerPlayer::ACTION::FOLD)

          round_manager.apply_action(table, 'raise', 100, action_checker)
          expect(round_manager.agree_num).to eq 0
        end

      end

      context "when passed action is allin" do
        before {
          setup_action_checker(player1, 0, 100)
          allow(action_checker).to receive(:correct_action).and_return ['raise', 100]
          allow(action_checker).to receive(:allin?).and_return true
        }

        it "should update player's pay_info" do
          expect(player1.pay_info).to receive(:update_to_allin)

          round_manager.apply_action(table, 'raise', 100, action_checker)
        end
      end

    end

    context "when not agreed player exists" do

      it "should ask action to him" do
        setup_action_checker(player1, 0, 5)
        expect(broadcaster).to receive(:ask).with(1, "ask_msg")

        expect {
          apply_action(round_manager, table, 'call', 5, action_checker)
        }.to change { round_manager.next_player }.by(1)
      end

    end

    context "when everyone agreed" do

      let(:deck) do
        deck = double("deck")
        allow(deck).to receive(:draw_cards).and_return([])
        deck
      end

      before {
        allow(seats).to receive(:count_active_player).and_return(3)
        allow(table).to receive(:dealer_btn).and_return(0)
        allow(table).to receive(:deck).and_return(deck)
        allow(broadcaster).to receive(:notification)

        round_manager.increment_agree_num
        round_manager.increment_agree_num
      }

      it "should clear player's action history but not pay_info" do
        setup_action_checker(player1, 0, 5)
        seats.players.each { |player|
          expect(player).to receive(:clear_action_histories)
          expect(player).not_to receive(:clear_pay_info)
        }

        apply_action(round_manager, table, 'call', 5, action_checker)
      end

      it "should forward to next street" do
        setup_action_checker(player1, 0, 5)
        expect(broadcaster).to receive(:notification).with("street_msg")

        apply_action(round_manager, table, 'call', 5, action_checker)
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

    def setup_table
      table = double("table")
      allow(table).to receive(:seats).and_return seat_with_active_players
      return table
    end

    def seat_with_active_players
      players =  (1..3).inject([]) do |acc, i|
        player = double("player#{i}")
        pay_info = double("pay info #{i}")
        allow(player).to receive(:active?).and_return(true)
        allow(player).to receive(:clear_action_histories)
        allow(player).to receive(:clear_pay_info)
        allow(player).to receive(:add_action_history)
        allow(player).to receive(:collect_bet)
        allow(player).to receive(:pay_info).and_return pay_info
        allow(player).to receive(:paid_sum).and_return 0
        allow(pay_info).to receive(:amount).and_return(0)
        allow(pay_info).to receive(:update_by_pay)
        acc << player
      end

      seats = double("seats")
      allow(seats).to receive(:players).and_return(players)
      allow(seats).to receive(:count_active_player).and_return 3
      allow(seats).to receive(:count_ask_wait_players).and_return 3
      allow(seats).to receive(:size).and_return(3)
      return seats
    end

    def deck_with_cards
      deck = double("deck")
      card = double("card")
      allow(card).to receive(:is_a?).with(Card).and_return(true)
      allow(deck).to receive(:draw_cards).and_return([card, card])
      allow(deck).to receive(:shuffle)
      deck
    end

    def setup_action_checker(player, pay_sum, need_amount)
      allow(player).to receive(:paid_sum).and_return(pay_sum)
      allow(action_checker).to receive(:need_amount_for_action).and_return(need_amount)
      allow(action_checker).to receive(:agree_amount).and_return(need_amount - pay_sum)
      allow(action_checker).to receive(:allin?).and_return(false)
    end

    def apply_action(round_manager, table, action, bet_amount, action_checker)
      allow(action_checker).to receive(:correct_action).and_return [action, bet_amount]
      round_manager.apply_action(table, action, bet_amount, action_checker)
    end

end

