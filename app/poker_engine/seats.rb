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

  def count_active_player
    @players.map { |p| p.active? }.select { |status| status }.size
  end

end

