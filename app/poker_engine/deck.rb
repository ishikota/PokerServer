class Deck

  # HOW TO CHEAT
  # deck = Deck.new(cheat=true, chat_cards=[card1, card2, card3])
  # > deck.draw_card
  # => card1
  def initialize(cheat=false, cheat_cards=nil)
    @cheat = cheat
    remember_cheat_cards(cheat_cards) if cheat
    @deck = setup
  end

  def draw_card
    @deck.pop
  end

  def draw_cards(num)
    (1..num).reduce([]) { |acc, e| acc << draw_card }
  end

  def size
    @deck.size
  end

  def restore
    @deck = setup
  end

  def shuffle
    @deck.shuffle! unless @cheat
  end

  private

    def setup
      @cheat ? setup_cheat_deck : setup_52_cards
    end

    def setup_52_cards
      (1..52).map { |i| Card.from_id(i) }
    end

    def setup_cheat_deck
      cards = @cheat_card_ids.map { |id| Card.from_id(id) }
      cards.reverse
    end

    def remember_cheat_cards(cards)
      @cheat_card_ids = cards.map { |card| card.to_id }
    end

end

