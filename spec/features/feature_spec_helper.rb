module FeatureSpecHelper

  C = Card::CLUB
  D = Card::DIAMOND
  H = Card::HEART
  S = Card::SPADE

  def cheat_deck
    p1_hole = [card(C,9), card(D,2)]  # no pair
    p2_hole = [card(C,8), card(D,3)]  # one pair
    flop_community = [card(D,3), card(D,5), card(C, 7)]
    turn_community = card(D,6)
    river_community = card(C,10)

    cards = [] << p1_hole << p2_hole \
        << flop_community << turn_community << river_community

    Deck.new(cheat=true, cheat_cards=cards.flatten)
  end

  def card(suit, rank)
    Card.new(suit, rank)
  end

end
