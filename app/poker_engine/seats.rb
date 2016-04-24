class Seats
  attr_reader :players

  def initialize
    @players = []
  end

  def sitdown(player)
    @players << player
  end

  def size
    @players.size
  end

  def collect_bet(idx, amount)
    @players[idx].collect_bet(amount)
  end

  def deactivate(idx)
    @players[idx].deactivate
  end

end

