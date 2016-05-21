class DealerMaker

  def create(room)
    Dealer.new(setup_components_holder(room))
  end

  def setup_components_holder(room)
    {}.merge(config: setup_config)
      .merge(table: setup_table)
      .merge(round_manager: setup_round_manager)
      .merge(action_checker: setup_action_checker)
      .merge(player_maker: setup_player_maker)
      .merge(message_builder: setup_message_builder)
  end


  private

    def setup_config
      Config.new(initial_stack=100, max_round=5)
    end

    def setup_table
      Table.new
    end

    def setup_game_evaluator
      hand_evaluator = HandEvaluator.new
      GameEvaluator.new(hand_evaluator)
    end

    def setup_round_manager
      game_evaluator = setup_game_evaluator
      message_builder = setup_message_builder
      RoundManager.new(game_evaluator, message_builder)
    end

    def setup_action_checker
      ActionChecker.new
    end

    def setup_player_maker
      PlayerMaker.new
    end

    def setup_message_builder
      game_evaluator = setup_game_evaluator
      data_formatter = DataFormatter.new(game_evaluator)
      MessageBuilder.new(data_formatter)
    end

end

