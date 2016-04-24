class Card
  attr_reader :suit

  # custom attr_reader
  def rank
    return @rank == 14 ? 1 : @rank
  end

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

  def to_id
    rank = @rank == 14 ? 1 : @rank
    tmp = @suit >> 1
    num = 0

    while tmp&1 != 1
      num += 1
      tmp >>= 1
    end

    binding.pry
    return rank + 13 * num
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

