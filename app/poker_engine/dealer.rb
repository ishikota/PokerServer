class Dealer

  def initialize(components_holder)
    @broadcaster = components_holder[:broadcaster]
    @config = components_holder[:config]
    @table = components_holder[:table]
    @round_manager = components_holder[:round_manager]
    @action_checker = components_holder[:action_checker]
    @player_maker = components_holder[:player_maker]
    @message_builder = components_holder[:message_builder]
    @round_count = 1
    @round_manager.set_finish_callback(finish_round_callback)
  end

  def start_game(player_info)
    players = player_info.map { |info| create_player(info) }
    set_player_to_seat(players)
    notify_game_start
    start_round
  end

  def receive_data(player_id, data)
    action, bet_amount = fetch_action_from_data(data)
    apply_action(action, bet_amount)
  end

  def teardown_round
    if played_all_round? || game_winner_is_decided?
      teardown_game
    else
      @round_count += 1
      excludes_no_money_player(@table.seats.players)
      @table.shift_dealer_btn
      start_round
    end
  end

  def teardown_game
    notify_game_result
  end

  def finish_round_callback
    lambda { |winners, accounting_info|
      notify_round_result(winners)
      teardown_round
    }
  end

  private


    def start_round
      @round_manager.start_new_round(@table)
    end

    def create_player(player_info)
      @player_maker.create(info=player_info, @config.initial_stack)
    end

    def set_player_to_seat(players)
      players.each { |player| @table.seats.sitdown(player) }
    end

    def apply_action(action, bet_amount)
      @round_manager.apply_action(@table, action, bet_amount, @action_checker)
    end

    def fetch_action_from_data(data)
      action = data["action"]
      bet_amount = data["bet_amount"]
      [action, bet_amount]
    end

    def played_all_round?
      @round_count == @config.max_round
    end

    def game_winner_is_decided?
      @table.seats.players.count { |player| player.stack != 0 } <= 1
    end

    def excludes_no_money_player(players)
      players.select { |player| player.stack == 0 }
        .each { |player| player.pay_info.update_to_fold }
    end

    def notify(message)
      @broadcaster.notification(message)
    end

    def notify_game_start
      message = @message_builder.game_start_message(@config, @table.seats)
      notify(message)
    end

    def notify_round_result(winners)
      message = @message_builder.round_result_message(winners, @round_manager, @table)
      notify(message)
    end

    def notify_game_result
      message = @message_builder.game_result_message(@table.seats)
      notify(message)
    end

end

