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
    cards = hole + community
    return STRAIGHTFLASH | eval_straightflash(cards) if straightflash?(cards)
    return FULLHOUSE | eval_fullhouse(cards) if fullhouse?(cards)
    return FLASH | eval_flash(cards) if flash?(cards)
    return STRAIGHT | eval_straight(cards) if straight?(cards)
    return THREECARD | eval_threecard(cards) if threecard?(cards)
    return TWOPAIR | eval_twopair(cards) if twopair?(cards)
    return ONEPAIR | (eval_onepair(cards) << 4) if onepair?(cards)
    eval_holecard(hole)
  end

  def eval_holecard(hole)
    ranks = hole.map { |card| card.rank }.sort
    ranks[1] << 4 | ranks[0]
  end

  def onepair?(cards)
    eval_onepair(cards) != -1
  end

  def eval_onepair(cards)
    rank = -1
    memo = 0 # bit memo
    for card in cards
      mask = 1 << card.rank
      rank = [rank, card.rank].max if memo & mask != 0
      memo |= mask
    end

    return rank
  end

  def twopair?(cards)
    search_twopair(cards).size == 2
  end

  def eval_twopair(cards)
    ranks = search_twopair(cards)
    ranks.reduce(0) { |acc, e| acc << 4 | e }
  end

  def search_twopair(cards)
    ranks = []
    memo = 0
    for card in cards
      mask = 1 << card.rank
      ranks = ranks.push(card.rank) if memo & mask != 0
      memo |= mask
    end

    return ranks.sort.reverse.take(2)
  end

  def threecard?(cards)
    search_threecard(cards) != -1
  end

  def eval_threecard(cards)
    search_threecard(cards) << 4
  end

  def search_threecard(cards)
    rank = -1
    bit_memo = cards.reduce(0) { |memo, card| memo += 1 << ((card.rank-1)*3) }
    for r in 2..14
      bit_memo >>= 3
      count = bit_memo & 7
      rank = r if count >= 3
    end

    return rank
  end

  def straight?(cards)
    search_straight(cards) != -1
  end

  def eval_straight(cards)
    search_straight(cards) << 4
  end

  def search_straight(cards)
    bit_memo = cards.reduce(0) { |memo, card| memo |= 1 << card.rank }

    rank = -1
    for r in 2..14
      rank = r if (0..4).reduce(true) { |acc, i| acc &= ((bit_memo >> (r+i)) & 1) == 1 }
    end

    return rank
  end

  def flash?(cards)
    search_flash(cards) != -1
  end

  def eval_flash(cards)
    search_flash(cards) << 4
  end

  def search_flash(cards)
    flash_suit = cards.group_by { |card| card.suit }
      .map { |key,vals| [key, vals.size] }
      .select { |idx, count| count >= 5 }
      .map { |tuple| tuple[0] }

    suit_max_rank = cards.group_by { |card| card.suit }
      .map { |key, vals| [key, vals.map{ |card| card.rank }] }
      .reduce({}) { |acc, keyval| acc.merge({ keyval[0] => keyval[1].max }) }

    return flash_suit.reduce(-1) { |acc, suit| [acc, suit_max_rank[suit]].max }
  end

  def fullhouse?(cards)
    r1, r2 = search_fullhouse(cards)
    return r1 && r2
  end

  def eval_fullhouse(cards)
    r1, r2 = search_fullhouse(cards)
    return r1 << 4 | r2
  end

  def search_fullhouse(cards)
    rank_count = cards.group_by { |card| card.rank }
    three_card_rank = rank_count.select { |rank, cards| cards.size >= 3 }.keys.max
    two_pair_rank = rank_count.select { |rank, cards| cards.size >= 2 }.keys.select { |rank| rank != three_card_rank }.max
    return [three_card_rank, two_pair_rank]
  end

  def straightflash?(cards)
    search_straightflash(cards) != -1
  end

  def eval_straightflash(cards)
    search_straightflash(cards) << 4
  end

  def search_straightflash(cards)
    flash_cards = cards.group_by { |card| card.suit }
      .select { |suit, cards| cards.size >= 5 }.values.flatten
    search_straight(flash_cards)
  end

  def mask_strength(bit)
    bit & (511 << 8)  # 511 = (1 << 9) -1
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

