class CommunityCard
  attr_reader :cards

  def initialize
    @cards = []
  end

  def add(card)
    raise full_msg if @cards.size == 5
    @cards << card
  end

  private

    def full_msg
      'Failed to add a card because community card is already full.'
    end

end

