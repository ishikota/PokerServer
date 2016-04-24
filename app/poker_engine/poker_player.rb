class PokerPlayer
  attr_reader :stack

  def initialize(initial_stack)
    @stack = initial_stack
  end

  def collect_bet(amount)
    raise "Failed to collect #{amount} chips. Because he has only #{@stack} chips." if @stack < amount
    @stack -= amount
  end

end

