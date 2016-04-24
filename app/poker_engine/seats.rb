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

end

