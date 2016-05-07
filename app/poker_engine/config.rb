class Config
  attr_accessor :initial_stack, :max_round, :small_blind_amount

  def initialize(initial_stack=100, max_round=10, small_blind_amount=5)
    @initial_stack = initial_stack
    @max_round = max_round
    @small_blind_amount = small_blind_amount
  end

end

