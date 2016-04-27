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

end

