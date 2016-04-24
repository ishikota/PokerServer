class RoundManager
  attr_reader :next_player, :agree_num, :street

  PREFLOP = 0
  FLOP = 1
  TURN = 2

  def initialize(broadcaster, finish_callback)
    @broadcaster = broadcaster
    @callback = finish_callback
    @street = 0
    @agree_num = 0
    @next_player = 0
  end

  def start_new_round(table)
    small_blind = 5
    @next_player = table.dealer_btn

    # collect blind
    table.seats.collect_bet(table.dealer_btn, small_blind)
    table.seats.collect_bet(shift_next_player(table.dealer_btn), small_blind * 2)
  end

  def apply_action(table, action, bet_amount)
    if action == 'call'
      table.seats.collect_bet(@next_player, bet_amount)
      table.pot.add_chip(bet_amount)
      increment_agree_num
    elsif action == 'fold'
      table.seats.deactivate(@next_player)
    elsif action =='raise'
      table.seats.collect_bet(@next_player, bet_amount)
      table.pot.add_chip(bet_amount)
      @agree_num = 1
    end

    if everyone_agree?(table.seats)
      @street += 1
      start_street(@street, table)
    else
      shift_next_player(table.seats)
      @broadcaster.ask(@next_player, "TODO")
    end
  end

  def start_street(street, table)
    if street == PREFLOP
      preflop(table)
    elsif street == FLOP
      flop(table)
    elsif street == TURN
      turn(table)
    end
  end

  def preflop(table)
    @next_player += 2  # skip blind player
    @broadcaster.ask(@next_player, "TODO")
  end

  def flop(table)
    for card in table.deck.draw_cards(3) do
      table.community_cards.add_card(card)
    end
    @broadcaster.ask(@next_player, "TODO")
  end

  def turn(table)
    table.community_cards.add_card(table.deck.draw_card)
    @broadcaster.ask(@next_player, "TODO")
  end

  def shift_next_player(seats)
    @next_player = (@next_player + 1) % seats.size
  end

  def everyone_agree?(seats)
    @agree_num == seats.size
  end

  def increment_agree_num
    @agree_num += 1
  end

end

