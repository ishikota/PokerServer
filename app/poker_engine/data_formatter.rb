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

end

