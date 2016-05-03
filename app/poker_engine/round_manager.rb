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

  def initialize(broadcaster, finish_callback, game_evaluator)
    @broadcaster = broadcaster
    @callback = finish_callback
    @game_evaluator = game_evaluator
    @street = 0
    @agree_num = 0
    @next_player = 0
  end

  def start_new_round(table)
    @next_player = table.dealer_btn
    @street = PREFLOP

    correct_blind(small_blind=5, table)
    deal_holecard(table.deck, table.seats.players)

    @broadcaster.notification("round info")
    start_street(@street, table)
  end

  def apply_action(table, action, bet_amount, action_checker)

    if action_checker.illegal?(table.seats.players, @next_player, action, bet_amount)
      action = 'fold'
    end

    if action == 'call'
      table.seats.collect_bet(@next_player, bet_amount)
      table.pot.add_chip(bet_amount)
      table.seats.players[@next_player]
          .add_action_history(PokerPlayer::ACTION::CALL, bet_amount)
      increment_agree_num
    elsif action == 'fold'
      table.seats.deactivate(@next_player)
      table.seats.players[@next_player].add_action_history(PokerPlayer::ACTION::FOLD)
    elsif action =='raise'
      table.seats.collect_bet(@next_player, bet_amount)
      table.pot.add_chip(bet_amount)
      table.seats.players[@next_player]
          .add_action_history(PokerPlayer::ACTION::RAISE, bet_amount)
      @agree_num = 1
    end

    if table.seats.count_active_player == 1
      @street = SHOWDOWN
      start_street(@street, table)
    elsif everyone_agree?(table.seats)
      @street += 1
      clear_action_histories(table.seats.players)
      start_street(@street, table)
    else
      shift_next_player(table.seats)
      @broadcaster.ask(@next_player, "TODO")
    end
  end

  def start_street(street, table)
    @agree_num = 0
    @next_player = table.dealer_btn
    @broadcaster.notification("#{STREET_MAP[street]} starts")

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

  def preflop(table)
    2.times { shift_next_player(table.seats) }
    @agree_num = 1  # big blind already agreed
    @broadcaster.ask(@next_player, "TODO")
  end

  def flop(table)
    for card in table.deck.draw_cards(3) do
      table.community_card.add(card)
    end
    @broadcaster.ask(@next_player, "TODO")
  end

  def turn(table)
    table.community_card.add(table.deck.draw_card)
    @broadcaster.ask(@next_player, "TODO")
  end

  def river(table)
    table.community_card.add(table.deck.draw_card)
    @broadcaster.ask(@next_player, "TODO")
  end

  def showdown(table)
    winner, accounting_info = @game_evaluator.judge(table)
    prize_to_winner(table.seats.players, accounting_info)
    table.reset
    @callback.call(winner, accounting_info)
  end

  def shift_next_player(exec_shift=true, seats)
    next_player = @next_player
    begin
      next_player = (next_player + 1) % seats.size
    end until seats.players[next_player].active?
    @next_player = next_player if exec_shift
    next_player
  end

  def everyone_agree?(seats)
    @agree_num == seats.count_active_player
  end

  def increment_agree_num
    @agree_num += 1
  end

  private

    def clear_action_histories(players)
      for player in players
        player.clear_action_histories
      end
    end

    def correct_blind(small_blind, table)
      small_blind_pos = table.dealer_btn
      big_blind_pos = shift_next_player(exec_shift=false, table.seats)

      table.seats.collect_bet(small_blind_pos, small_blind)
      table.seats.collect_bet(big_blind_pos, small_blind * 2)

      table.seats.players[small_blind_pos].add_action_history(PokerPlayer::ACTION::RAISE, small_blind)
      table.seats.players[big_blind_pos].add_action_history(PokerPlayer::ACTION::RAISE, small_blind * 2)
    end

    def deal_holecard(deck, players)
      for player in players
        player.add_holecard(deck.draw_cards(2))
      end
    end

    def prize_to_winner(players, accounting_info)
      accounting_info.each { |idx, prize|
        players[idx].append_chip(prize)
      }
    end


end

