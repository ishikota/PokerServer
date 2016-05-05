class GameEvaluator

  def initialize(hand_evaluator)
    @hand_evaluator = hand_evaluator
  end

  def judge(table)
    winners = find_winners_from(table.community_card.cards, table.seats.players)
    prize_map = calc_prize_distribution(table.community_card.cards, table.seats.players)
    return [winners, prize_map]
  end

  # public for test
  def find_winners_from(community_card, players)
    players
      .select { |player| player.active? }
      .group_by { |player|
        @hand_evaluator.eval_hand(player.hole_card, community_card)
      }.max.last
  end

  # public for test
  def create_pot(players)
    side_pots = get_side_pots(players)
    main_pot = get_main_pot(players, side_pots)
    return side_pots << main_pot
  end


  private

    def calc_prize_distribution(community_card, players)
      prize_map = create_prize_map(players.size)
      pots = create_pot(players)

      pots.each { |pot|
        winners = find_winners_from(community_card, pot[:eligibles])
        prize = pot[:amount] / winners.size
        winners.each { |winner| prize_map[players.index(winner)] += prize }
      }

      prize_map
    end

    def create_prize_map(player_num)
      (0..player_num-1).reduce({}) { |map, idx| map.merge( { idx => 0 } ) }
    end

    def get_main_pot(players, side_pots)
      max_pay = get_payinfo(players).max_by { |pay| pay.amount }.amount
      {
        amount: get_players_pay_sum(players) - get_sidepots_sum(side_pots),
        eligibles: players.select { |player| player.pay_info.amount == max_pay }
      }
    end

    def get_side_pots(players)
      fetch_allin_payinfo(players)
        .map{ |payinfo| payinfo.amount }
        .reduce([]) { |side_pots, allin_amount|
          side_pots << create_sidepot(players, side_pots, allin_amount)
        }
    end

    def create_sidepot(players, smaller_side_pots, allin_amount)
      {
        amount: calc_sidepot_size(players, smaller_side_pots, allin_amount),
        eligibles: select_eligibles(players, allin_amount)
      }
    end

    def calc_sidepot_size(players, smaller_side_pots, allin_amount)
      target_pot_size = players.reduce(0) { |pot, player| pot + [allin_amount, player.pay_info.amount].min }
      target_pot_size - get_sidepots_sum(smaller_side_pots)
    end

    def get_sidepots_sum(side_pots)
      side_pots.reduce(0) { |sum, side_pot| sum + side_pot[:amount] }
    end

    def select_eligibles(players, allin_amount)
      players.select { |player| eligible?(player, allin_amount) }
    end

    def eligible?(player, allin_amount)
      player.pay_info.amount >= allin_amount && player.pay_info.status != PokerPlayer::PayInfo::FOLDED
    end

    def get_players_pay_sum(players)
      get_payinfo(players).reduce(0) { |sum, pay| sum + pay.amount }
    end

    def fetch_allin_payinfo(players)
        get_payinfo(players)
          .select  { |pay_info| pay_info.status == PokerPlayer::PayInfo::ALLIN }
          .sort_by { |pay_info| pay_info.amount }
    end

    def get_payinfo(players)
      players.map { |player| player.pay_info }
    end

end

