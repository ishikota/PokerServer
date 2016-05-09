class RoundManager
  attr_reader :next_player, :agree_num, :street

  PREFLOP = 0
  FLOP = 1
  TURN = 2
  RIVER = 3
  SHOWDOWN = 4

  STREET_MAP = {
    PREFLOP  => "PREFLOP",
    FLOP     => "FLOP",
    TURN     => "TURN",
    RIVER    => "RIVER",
    SHOWDOWN => "SHOWDOWN"
  }

  def initialize(broadcaster, game_evaluator, message_builder)
    @broadcaster = broadcaster
    @game_evaluator = game_evaluator
    @message_builder = message_builder
    @street = 0
    @agree_num = 0
    @next_player = 0
  end

  def set_finish_callback(finish_callback)
    @callback = finish_callback
  end

  def start_new_round(table)
    @next_player = table.dealer_btn
    @street = PREFLOP

    table.deck.shuffle
    correct_blind(small_blind=5, table)
    deal_holecard(table.deck, table.seats.players)

    notify_round_start(table)
    start_street(@street, table)
  end

  def apply_action(table, action, bet_amount, action_checker)
    action_player = table.seats.players[@next_player]

    action, bet_amount = action_checker.correct_action(
        table.seats.players, @next_player, action, bet_amount)
    action_player.pay_info.update_to_allin if action_checker.allin?(action_player, action, bet_amount)

    accept_action(action_player, action, bet_amount, table.seats.players, action_checker)
    notify_update(@next_player, action, bet_amount, table)

    if everyone_agree?(table.seats)
      @street += 1
      clear_action_histories(table.seats.players)
      start_street(@street, table)
    else
      shift_next_player(table.seats)
      send_ask_message(@next_player, self, table)
    end
  end

  # public for test
  def start_street(street, table)
    @agree_num = 0
    @next_player = table.dealer_btn
    notify_street_start(table)

    if street == PREFLOP
      preflop(table)
    elsif street == FLOP
      flop(table)
    elsif street == TURN
      turn(table)
    elsif street == RIVER
      river(table)
    elsif street == SHOWDOWN
      showdown(table)
    end
  end

  # public for test
  def shift_next_player(exec_shift=true, seats)
    next_player = @next_player
    begin
      next_player = (next_player + 1) % seats.size
    end until seats.players[next_player].active?
    @next_player = next_player if exec_shift
    next_player
  end

  # public for test
  def everyone_agree?(seats)
    @agree_num == seats.count_active_player
  end

  # public for test
  def increment_agree_num
    @agree_num += 1
  end

  private

    def preflop(table)
      2.times { shift_next_player(table.seats) }
      @agree_num = 1  # big blind already agreed
      ask_if_needed(table)
    end

    def flop(table)
      table.deck.draw_cards(3).each { |card|
        table.community_card.add(card)
      }
      ask_if_needed(table)
    end

    def turn(table)
      table.community_card.add(table.deck.draw_card)
      ask_if_needed(table)
    end

    def river(table)
      table.community_card.add(table.deck.draw_card)
      ask_if_needed(table)
    end

    def showdown(table)
      winner, accounting_info = @game_evaluator.judge(table)
      prize_to_winner(table.seats.players, accounting_info)
      table.reset
      @callback.call(winner, accounting_info)
    end

    def prize_to_winner(players, accounting_info)
      accounting_info.each { |idx, prize|
        players[idx].append_chip(prize)
      }
    end

    def deal_holecard(deck, players)
      players.each { |player| player.add_holecard(deck.draw_cards(2)) }
    end

    def correct_blind(small_blind, table)
      small_blind_pos = table.dealer_btn
      big_blind_pos = shift_next_player(exec_shift=false, table.seats)

      sb_player = table.seats.players[small_blind_pos]
      bb_player = table.seats.players[big_blind_pos]

      blind_transaction(sb_player, small_blind)
      blind_transaction(bb_player, small_blind * 2)
    end

    def blind_transaction(player, blind_amount)
      player.collect_bet(blind_amount)
      player.add_action_history(PokerPlayer::ACTION::RAISE, blind_amount, 5)
      player.pay_info.update_by_pay(blind_amount)
    end

    def accept_action(player, action, bet_amount, players, action_checker)
      if action == 'call'
        chip_transaction(action_checker, player, bet_amount)
        player.add_action_history(PokerPlayer::ACTION::CALL, bet_amount)
        increment_agree_num
      elsif action == 'raise'
        chip_transaction(action_checker, player, bet_amount)
        add_amount = bet_amount - action_checker.agree_amount(players)
        player.add_action_history(PokerPlayer::ACTION::RAISE, bet_amount, add_amount)
        @agree_num = 1
      elsif action == 'fold'
        player.add_action_history(PokerPlayer::ACTION::FOLD)
        player.pay_info.update_to_fold
      end
    end

    def chip_transaction(action_checker, player, bet_amount)
      need_amount = action_checker.need_amount_for_action(player, bet_amount)
      player.collect_bet(need_amount)
      player.pay_info.update_by_pay(need_amount)
    end

    def ask_if_needed(table)
      if table.seats.count_ask_wait_players == 1
        @street += 1
        start_street(@street, table)
      else
        send_ask_message(@next_player, self, table)
      end
    end

    def clear_action_histories(players)
      players.each { |player| player.clear_action_histories }
    end

    def ask(player_pos, message)
      @broadcaster.ask(player_pos, message)
    end
    def notify(message)
      @broadcaster.notification(message)
    end

    def notify_round_start(table)
      table.seats.players.each_with_index { |player, idx|
        #TODO fix to notify to each person
        notify(@message_builder.round_start_message(idx, table.seats))
      }
    end

    def notify_street_start(table)
      notify(@message_builder.street_start_message(self, table))
    end

    def notify_update(player_pos, action, amount, table)
      message = @message_builder.game_update_message(player_pos, action, amount, self, table)
      notify(message)
    end

    def send_ask_message(player_pos, round_manager, table)
      action_checker = ActionChecker.new  #TODO
      message = @message_builder.ask_message(action_checker, player_pos, round_manager, table)
      next_player = table.seats.players[player_pos]
      ask(next_player.uuid, message)
    end

end

