class RoundManager
  attr_reader :next_player, :agree_num

  def initialize(broadcaster, finish_callback)
    @broadcaster = broadcaster
    @callback = finish_callback
    @street = 0
    @agree_num = 0
    @next_player = 0
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

