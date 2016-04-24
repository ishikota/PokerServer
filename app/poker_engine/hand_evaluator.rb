class HandEvaluator

  HIGHCARD      = 0
  ONEPAIR       = 1 << 8
  TWOPAIR       = 1 << 9
  THREECARD     = 1 << 10
  STRAIGHT      = 1 << 11
  FLASH         = 1 << 12
  FULLHOUSE     = 1 << 13
  FOURCARD      = 1 << 14
  STRAIGHTFLASH = 1 << 15

  # Return Format
  # [Bit flg of hand][rank1(4bit)][rank2(4bit)]
  # ex.)
  #       HighCard hole card 3,4   =>           100 0011
  #       OnePair of rank 3        =>        1 0011 0000
  #       TwoPair of rank A, 4     =>       10 1110 0100
  #       ThreeCard of rank 9      =>      100 1001 0000
  #       Straight of rank 10      =>     1000 1010 0000
  #       Flash of rank 5          =>    10000 0101 0000
  #       FullHouse of rank 3, 4   =>   100000 0011 0100
  #       FourCard of rank 2       =>  1000000 0010 0000
  #       straight flash of rank 7 => 10000000 0111 0000
  def eval_hand(hole, community)
    eval_holecard(hole)
  end

  def eval_holecard(hole)
    ranks = hole.map { |card| card.rank == 1 ? 14 : card.rank }.sort
    ranks[1] << 4 | ranks[0]
  end

  def mask_strength(bit)
    bit >> 8
  end

  def mask_high_rank(bit)
    mask = 15 << 4
    (bit & mask) >> 4
  end

  def mask_low_rank(bit)
    mask = 15
    bit & mask
  end

end

