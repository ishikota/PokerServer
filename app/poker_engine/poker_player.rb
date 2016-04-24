class PokerPlayer
  attr_reader :stack

  def initialize(initial_stack)
    @stack = initial_stack
    @active = true
  end

  def collect_bet(amount)
    raise "Failed to collect #{amount} chips. Because he has only #{@stack} chips." if @stack < amount
    @stack -= amount
  end

  def deactivate
    @active = false
  end

  def active?
    @active
  end

end

