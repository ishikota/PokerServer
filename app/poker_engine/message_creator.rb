class MessageCreator

  module Type
    GAME_START_MESSAGE = "game_start_message"
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

end

