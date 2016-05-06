class MessageBuilder

  module Type
    GAME_START_MESSAGE = "game_start_message"
    ROUND_START_MESSAGE = "round_start_message"
    STREET_START_MESSAGE = "street_start_message"
    ASK_MESSAGE = "ask_message"
    GAME_UPDATE_MESSAGE = "game_update_message"
    ROUND_RESULT_MESSAGE = "round_result_message"
    GAME_RESULT_MESSAGE = "game_result_message"
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

  def street_start_message(round_manager, table)
    street = @formatter.format_street(round_manager.street)
    round_state = @formatter.format_round_state(round_manager, table)
    {
      "message_type" => Type::STREET_START_MESSAGE,
      "round_state" => round_state
    }.merge!(street)
  end

  def ask_message(action_checker, player_pos, round_manager, table)
    player = table.seats.players[player_pos]
    hole_card = @formatter.format_player(player, holecard=true)["hole_card"]
    valid_actionis = action_checker.legal_actions(table.seats.players, player_pos)
    round_state = @formatter.format_round_state(round_manager, table)
    action_histories = @formatter.format_action_histories(table)

    {
      "message_type" => Type::ASK_MESSAGE,
      "hole_card" => hole_card,
      "valid_actionis" => valid_actionis,
      "round_state" => round_state,
      "action_histories" => action_histories
    }
  end

  def game_update_message(player_pos, action, amount, round_manager, table)
    player = table.seats.players[player_pos]
    action = @formatter.format_action(player, action, amount)
    round_state = @formatter.format_round_state(round_manager, table)
    action_histories = @formatter.format_action_histories(table)

    {
      "message_type" => Type::GAME_UPDATE_MESSAGE,
      "action" => action,
      "round_state" => round_state,
      "action_histories" => action_histories
    }
  end

  def round_result_message(winners, round_manager, table)
    winners = @formatter.format_winners(winners)
    round_state = @formatter.format_round_state(round_manager, table)

    {
      "message_type" => Type::ROUND_RESULT_MESSAGE,
      "round_state" => round_state
     }.merge!(winners)
  end

  def game_result_message(seats)
    { "message_type" => Type::GAME_RESULT_MESSAGE }
      .merge!(@formatter.format_seats(seats))
  end

end

