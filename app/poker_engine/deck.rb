class Deck

  # HOW TO CHEAT
  # deck = Deck.new(cheat=true, chat_cards=[card1, card2, card3])
  # > deck.draw_card
  # => card1
  def initialize(cheat=false, cheat_cards=nil)
    if cheat
      setup_cheat_deck(cheat_cards)
    else
      setup_52_cards
    end
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
    setup_52_cards
  end

  private

    def setup_52_cards
      @deck = []
      for id in 1..52
        @deck << Card.from_id(id)
      end
    end

    def setup_cheat_deck(cards)
      @deck = cards.reverse
    end
end

