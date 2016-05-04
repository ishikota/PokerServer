class Dealer

  def initialize(components_holder)
    @broadcaster = components_holder[:broadcaster]
    @config = components_holder[:config]
    @table = components_holder[:table]
    @round_manager = components_holder[:round_manager]
    @action_checker = components_holder[:action_checker]
    @player_maker = components_holder[:player_maker]
    @round_count = 0
    @round_manager.set_finish_callback(finish_round_callback)
  end

  def start_game(player_info)
    players = player_info.map { |info| create_player(info) }
    set_player_to_seat(players)
    @broadcaster.notification(game_information_message)
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
    @broadcaster.notification(goodbye_message)
  end

  # private

    def finish_round_callback
      lambda { |winners, accounting_info|
        @broadcaster.notification(game_result_message(@table, winners, accounting_info))
        teardown_round
      }
    end

    def start_round
      @round_manager.start_new_round(@table)
    end

    def create_player(info)
      @player_maker.create(name=info, @config.initial_stack) #TODO use passed info
    end

    def set_player_to_seat(players)
      for player in players
        @table.seats.sitdown(player)
      end
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

    def game_information_message
      "TODO game info"
    end

    def game_result_message(table, winners, accounting_info)
      "TODO game result"
    end

    def goodbye_message
      "TODO goodbye"
    end

    def apply_action(action, bet_amount)
      @round_manager.apply_action(@table, action, bet_amount, @action_checker)
    end

    def fetch_action_from_data(data)
      action = data["action"]
      bet_amount = data["bet_amount"]
      [action, bet_amount]
    end


end

