class ActionChecker

  def correct_action(players, player_pos, action, amount=nil)
    if allin?(players[player_pos], action, amount)
      amount = players[player_pos].stack
    elsif illegal?(players, player_pos, action, amount)
      action = 'fold'
      amount = 0
    end
    [action, amount]
  end

  def illegal?(players, player_pos, action, amount=nil)
    if action == 'fold'
      return false
    elsif action == 'call'
      return short_of_money?(players[player_pos], amount) \
          || illegal_call?(players, amount)
    elsif action == 'raise'
      return short_of_money?(players[player_pos], amount) \
          || illegal_raise?(players, amount)
    end
  end

  def allin?(player, action, bet_amount)
    if action == 'call'
      bet_amount >= player.stack
    elsif action == 'raise'
      bet_amount == player.stack
    else
      false
    end
  end

  def legal_actions(players, player_pos)
    player = players[player_pos]
    min_raise = min_raise_amount(players)
    pay_max = player.stack + player.paid_sum
    actions = []
    actions << { "action" => "fold", "amount" => 0 }
    actions << { "action" => "call", "amount" => agree_amount(players) }
    actions << { "action" => "raise", "amount" => { "min" => min_raise, "max" => pay_max } }
  end

  def need_amount_for_action(player, amount)
    amount - player.paid_sum
  end

  def agree_amount(players)
    last_raise = fetch_last_raise(players)
    last_raise.nil? ? 0 : last_raise["amount"]
  end

  private

    DEFAULT_MIN_RAISE = 5

    def short_of_money?(player, amount)
      player.stack < amount - player.paid_sum
    end

    def illegal_call?(players, amount)
      amount != agree_amount(players)
    end

    def illegal_raise?(players, amount)
      min_raise_amount(players) > amount
    end

    def min_raise_amount(players)
      last_raise = fetch_last_raise(players)
      last_raise.nil? ? DEFAULT_MIN_RAISE : last_raise["amount"] + last_raise["add_amount"]
    end


    def fetch_last_raise(players)
      players.map { |player|
        player.action_histories
      }
      .flatten
      .select { |history|
        history["action"] == "RAISE"
      }.max_by { |history|
        history["amount"]
      }
    end

end
