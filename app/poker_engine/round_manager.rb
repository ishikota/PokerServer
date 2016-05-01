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
    small_blind = 5
    @next_player = table.dealer_btn
    @street = PREFLOP

    # collect blind
    table.seats.collect_bet(table.dealer_btn, small_blind)
    table.seats.collect_bet(shift_next_player(exec_shift=false, table.seats), small_blind * 2)

    @broadcaster.notification("round info")
    start_street(@street, table)
  end

  def apply_action(table, action, bet_amount, action_checker)

    action = 'fold' if action_checker.illegal?(action)

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

end

