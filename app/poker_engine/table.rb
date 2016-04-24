class Table
  attr_reader :dealer_btn, :seats, :pot, :deck, :community_card

  def initialize
    @dealer_btn = 0
    @seats = Seats.new
    @pot = Pot.new
    @deck = Deck.new
    @community_card = CommunityCard.new
  end

end

