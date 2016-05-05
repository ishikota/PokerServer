class DataFormatter

  def format_player(player, holecard=false)
    hash = JSON.parse(player.to_json)
    hash.delete("action_histories")
    hash.delete("hole_card")
    hash.delete("pay_info")
    hash.merge!( { "state" => player.pay_info.status } )
    hash.merge!( { "hole_card" => player.hole_card.map { |card| card.to_s } } ) if holecard
    return hash
  end

  def format_seats(seats)
    players = seats.players.map { |player| format_player(player) }
    { "seats" => players }
  end

  def format_game_information(config, seats)
    hash = {}
    hash.merge!( { "player_num" => seats.players.size } )
    hash.merge!( { "seats" => format_seats(seats) } )
    hash.merge!( { "rule" => JSON.parse(config.to_json) } )
  end

  def format_valid_actions(call_amount, min_bet_amount, max_bet_amount)
    hash = {}
    ary = []
    ary << { "action" => "fold", "amount" => 0 }
    ary << { "action" => "call", "amount" => call_amount }
    ary << { "action" => "raise", "amount" => { "min" => min_bet_amount, "max" => max_bet_amount } }
    hash.merge!( { "valid_actions" => ary } )
  end

  def format_action(player, action, amount)
    {
      "player" => format_player(player),
      "action" => action,
      "amount" => amount
    }
  end

  def format_street(street)
    street_str = RoundManager::STREET_MAP[street]
    raise "Unexpected street [#{street}] is passed" if street_str.nil?
    { "street" => street_str }
  end

end

