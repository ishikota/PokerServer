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

  def count_active_player
    @players.map { |p| p.active? }.select { |status| status }.size
  end

end

