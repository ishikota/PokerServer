class Table
  attr_reader :dealer_btn, :seats, :pot, :deck, :community_card

  def initialize(cheat_deck=nil)
    @dealer_btn = 0
    @seats = Seats.new
    @pot = Pot.new
    @deck = cheat_deck.nil? ? Deck.new : cheat_deck
    @community_card = CommunityCard.new
  end


end

