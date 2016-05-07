class Table
  attr_reader :dealer_btn, :seats, :deck, :community_card

  def initialize(cheat_deck=nil)
    @dealer_btn = 0
    @seats = Seats.new
    @deck = cheat_deck.nil? ? Deck.new : cheat_deck
    @community_card = CommunityCard.new
  end

  def reset
    @deck.restore
    @community_card.clear
    @seats.players.each { |player|
      player.clear_holecard
      player.clear_action_histories
      player.clear_pay_info
    }
  end

  def shift_dealer_btn
    begin
      @dealer_btn = (@dealer_btn + 1) % @seats.size
    end until @seats.players[@dealer_btn].active?
  end

end

