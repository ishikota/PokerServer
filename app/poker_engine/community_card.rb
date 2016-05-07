class CommunityCard
  attr_reader :cards

  def initialize
    @cards = []
  end

  def add(card)
    raise full_msg if @cards.size == 5
    @cards << card
  end

  def clear
    @cards = []
  end

  private

    def full_msg
      'Failed to add a card because community card is already full.'
    end

end

