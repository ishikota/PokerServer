class GameEvaluator

  def initialize(hand_evaluator)
    @hand_evaluator = hand_evaluator
  end

  def find_winner_from(community_card, players)
    players.group_by { |player|
      @hand_evaluator.eval_hand(player.hole_card, community_card)
    }.max.last
  end

end

