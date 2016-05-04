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
    @players.count { |p| p.active? }
  end

  def count_ask_wait_players
    @players.count { |p|
      p.pay_info.status == PokerPlayer::PayInfo::PAY_TILL_END
    }
  end

end

