class Config
  attr_accessor :initial_stack, :max_round

  def initialize(initial_stack=100, max_round=10)
    @initial_stack = initial_stack
    @max_round = max_round
  end

end

