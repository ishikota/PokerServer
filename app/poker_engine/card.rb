class Card

  CLUB = 2
  DIAMOND = 4
  HEART = 8
  SPADE = 16

  def initialize(suit, rank)
    rank = 14 if rank == 1
    @suit = suit
    @rank = rank
  end

  def to_s
    "#{SUIT_MAP[@suit]}#{RANK_MAP[@rank]}"
  end

  private

    # rank 2~A is converted into 2~14.
    # Be careful that Ace is converted to 14 !!
    RANK_MAP = {
      2  =>  '2',
      3  =>  '3',
      4  =>  '4',
      5  =>  '5',
      6  =>  '6',
      7  =>  '7',
      8  =>  '8',
      9  =>  '9',
      10 => 'T',
      11 => 'J',
      12 => 'Q',
      13 => 'K',
      14 => 'A'
    }

    SUIT_MAP = {
      CLUB => 'C',
      DIAMOND => 'D',
      HEART => 'H',
      SPADE => 'S'
    }

end

