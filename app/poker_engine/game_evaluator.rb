class GameEvaluator

  def initialize(hand_evaluator)
    @hand_evaluator = hand_evaluator
  end

  def judge(table)
    winners = find_winner_from(table.community_card, table.seats.players)
    prize_map = calc_prize_distribution(table.pot, winners, table.seats.players)
    return [winners, prize_map]
  end

  def find_winner_from(community_card, players)
    players.group_by { |player|
      @hand_evaluator.eval_hand(player.hole_card, community_card)
    }.max.last
  end

  def create_side_pot(players)
    side_pots = get_side_pots(players)
    main_pot = get_main_pot(players, side_pots)
    return side_pots << main_pot
  end


  private

    def calc_prize_distribution(pot, winners, players)
      prize = pot.main/winners.size
      players.each_with_index.select { |player, idx|
        winners.include?(player)
      }.reduce({}) { |map, player_with_idx|
        _, idx = player_with_idx
        map.merge( { idx => prize } )
      }
    end

    def get_side_pots(players)
      side_pots = []
      allin_payinfo = fetch_allin_payinfo(players)

      for allin_amount in allin_payinfo.map{ |payinfo| payinfo.amount }
        pot, eligibles = 0, []

        for player in players
          payinfo = player.pay_info

          pot += [allin_amount, player.pay_info.amount].min
          if payinfo.amount >= allin_amount && payinfo.status != PokerPlayer::PayInfo::FOLDED
            eligibles << player
          end

        end

        pot -= side_pots.reduce(0) { |sum, side_pot| sum + side_pot[:amount] }
        side_pots << { amount: pot, eligibles: eligibles }
      end

      return side_pots
    end

    def get_main_pot(players, side_pots)
      payinfo = get_payinfo(players)
      pay_sum = payinfo.reduce(0) { |sum, pay| sum + pay.amount }
      sidepot_sum = side_pots.reduce(0) { |sum, side_pot| sum + side_pot[:amount] }
      left_chip = pay_sum - sidepot_sum
      max_pay = payinfo.max_by { |pay| pay.amount }.amount
      eligibles = players.select { |player| player.pay_info.amount == max_pay }
      return { amount: left_chip, eligibles: eligibles }
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

