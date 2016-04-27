class PokerPlayer
  attr_reader :stack, :pay_info

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

  def init_pay_info
    @pay_info = PayInfo.new
  end

  class PayInfo
    attr_reader :amount, :status

    PAY_TILL_END = 0
    ALLIN  = 1
    FOLDED = 2

    def initialize
      @amount = 0
      @status = PAY_TILL_END
    end

    def update_by_pay(amount)
      @amount += amount
    end

    def update_to_fold
      @status = FOLDED
    end

    def update_to_allin(amount)
      @amount += amount
      @status = ALLIN
    end

  end

end

