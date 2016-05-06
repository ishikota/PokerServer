class MessageCreator

  module Type
    GAME_START_MESSAGE = "game_start_message"
    ROUND_START_MESSAGE = "round_start_message"
  end

  def initialize(data_formatter)
    @formatter = data_formatter
  end

  def game_start_message(config, seats)
    game_info = @formatter.format_game_information(config, seats)
    {
      "message_type" => Type::GAME_START_MESSAGE,
      "game_information" => game_info
    }
  end

  def round_start_message(player_pos, seats)
    player = seats.players[player_pos]
    hole_card = @formatter.format_player(player, holecard=true)["hole_card"]
    {
      "message_type" => Type::ROUND_START_MESSAGE,
      "seats" => @formatter.format_seats(seats),
      "hole_card" => hole_card
    }
  end

end

