class PokerPlayer
  attr_reader :name, :stack, :pay_info, :action_histories, :hole_card

  def initialize(name="No Name", initial_stack)
    @name = name
    @hole_card = []
    @stack = initial_stack
    @action_histories = []
    @pay_info = PayInfo.new
  end

  def collect_bet(amount)
    raise "Failed to collect #{amount} chips. Because he has only #{@stack} chips." if @stack < amount
    @stack -= amount
  end

  def active?
    @pay_info.status != PayInfo::FOLDED
  end

  def clear_holecard
    @hole_card = []
  end

  def clear_action_histories
    @action_histories = []
  end

  def clear_pay_info
    @pay_info = PayInfo.new
  end

  def append_chip(amount)
    @stack += amount
  end

  def add_holecard(cards)
    raise "Hole card is already set" unless @hole_card.empty?
    raise "You passing wrong number of cards #{cards.size}" unless cards.size == 2
    raise "what you are passing are not cards" unless cards.map { |card| card.is_a?(Card) }.all?
    @hole_card = cards
  end


  def add_action_history(kind, chip_amount=nil, add_amount=nil)
    if kind == ACTION::FOLD
      @action_histories << fold_history
    elsif kind == ACTION::CALL
      @action_histories << call_history(chip_amount)
    elsif kind == ACTION::RAISE
      @action_histories << raise_history(chip_amount, add_amount)
    else
      raise "Un expected action kind #{kind} passed"
    end
  end

  def paid_sum
    last_history = action_histories.select {|h| h["action"] != 'FOLD'}.last
    last_history.nil? ? 0 : last_history["amount"]
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

    def raise_history(bet_amount, add_amount)
      {
        "action" => "RAISE",
        "amount" => bet_amount,
        "paid" => bet_amount - paid_sum,
        "add_amount" => add_amount
      }
    end

end

