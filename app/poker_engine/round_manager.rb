class RoundManager
  attr_reader :next_player, :agree_num

  def initialize(broadcaster, finish_callback)
    @broadcaster = broadcaster
    @callback = finish_callback
    @street = 0
    @agree_num = 0
    @next_player = 0
  end

  def apply_action(table, action, bet_amount)
    if action == 'call'
      table.seats.collect_bet(@next_player, bet_amount)
      table.pot.add_chip(bet_amount)
      increment_agree_num
    end
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

