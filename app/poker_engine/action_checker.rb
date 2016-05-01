class ActionChecker

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

  private

    def short_of_money?(player, amount)
      player.stack < amount
    end

    def illegal_call?(players, amount)
      amount != agree_amount(players)
    end

    def illegal_raise?(players, amount)
      last_raise = fetch_last_raise(players)
      min_raise = last_raise["amount"] + last_raise["add_amount"]
      min_raise > amount
    end

    def agree_amount(players)
      last_raise = fetch_last_raise(players)
      last_raise.nil? ? 0 : last_raise["amount"]
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
