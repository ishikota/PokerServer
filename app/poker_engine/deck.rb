class Deck

  def initialize
    setup_52_cards
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

  private

    def setup_52_cards
      @deck = []
      for id in 1..52
        @deck << Card.from_id(id)
      end
    end
end

