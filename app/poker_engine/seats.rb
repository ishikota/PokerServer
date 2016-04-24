class Seats
  attr_reader :players

  def initialize
    @players = []
  end

  def sitdown(player)
    @players << player
  end

end

