class PokerPlayer
  attr_reader :stack, :pay_info, :action_histories

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

  def init_action_histories
    @action_histories = []
  end

  def init_pay_info
    @pay_info = PayInfo.new
  end

  def add_action_history(kind, chip_amount=nil)
    if kind == ACTION::FOLD
      @action_histories << fold_history
    elsif kind == ACTION::CALL
      @action_histories << call_history(chip_amount)
    elsif kind == ACTION::RAISE
      @action_histories << raise_history(chip_amount)
    else
      raise "Un expected action kind #{kind} passed"
    end
  end

  def invalidate_last_action
    raise 'Try to invalidate last action but no action history is found' if action_histories.empty?
    action_histories.pop
    action_histories << fold_history
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

  module ACTION
    FOLD = 0
    CALL = 1
    RAISE = 2
  end


  private

    def fold_history
      { "action" => "FOLD" }
    end

    def call_history(amount)
      {
        "action" => "CALL",
        "amount" => amount,
        "paid" => amount - paid_sum
      }
    end

    def raise_history(amount)
      {
        "action" => "RAISE",
        "amount" => amount,
        "paid" => amount - paid_sum
      }
    end

    def paid_sum
      last_history = action_histories.select {|h| h["action"] != 'FOLD'}.last
      last_history.nil? ? 0 : last_history["amount"]
    end

end

