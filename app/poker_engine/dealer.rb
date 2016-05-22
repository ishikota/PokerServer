class Dealer
  include DealerSerializer

  def initialize(components_holder, round_count=1)
    @config = components_holder[:config]
    @table = components_holder[:table]
    @round_manager = components_holder[:round_manager]
    @action_checker = components_holder[:action_checker]
    @player_maker = components_holder[:player_maker]
    @message_builder = components_holder[:message_builder]
    @round_count = round_count
    @round_manager.set_finish_callback(finish_round_callback)
  end

  def start_game(player_info)
    players = player_info.map { |info| create_player(info) }
    set_player_to_seat(players)
    msgs = []
    msgs << notify_game_start
    msgs << start_round
    msgs.flatten
  end

  def receive_data(uuid, data)
    if message_from_expected_player?(uuid, @table.seats, @round_manager.next_player)
      action, bet_amount = fetch_action_from_data(data)
      apply_action(action, bet_amount)
    else
      puts "Reject message from unexpected player: message = #{data}"
    end
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
      msgs = []
      msgs << notify_round_result(winners)
      msgs << teardown_round
      msgs.flatten
    }
  end

  def dump
    config = Marshal.dump(@config)
    table = Marshal.dump(@table)
    build_state_dump(config, table).to_json
  end

  def load(components_holder, dump)
    dt = JSON.parse(dump)
    round_manager = build_round_manager(dt["round_manager"])
    components_holder.merge!( { "config" => dt["config"] } )
    components_holder.merge!( { "table" => dt["table"] } )
    Deler.new(components_holder, dt["round_count"])
  end

  private

    def start_round
      @round_manager.start_new_round(@round_count, @table)
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
      action = data["poker_action"]
      bet_amount = data["bet_amount"]
      [action, bet_amount]
    end

    def message_from_expected_player?(messanger_uuid, seats, next_player_pos)
      expected_player = seats.players[next_player_pos]
      expected_player.uuid == messanger_uuid
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

    def notify_game_start
      message = @message_builder.game_start_message(@config, @table.seats)
      notification_message(message)
    end

    def notify_round_result(winners)
      message = @message_builder.round_result_message(@round_count, winners, @round_manager, @table)
      notification_message(message)
    end

    def notify_game_result
      message = @message_builder.game_result_message(@table.seats)
      notification_message(message)
    end

    def notification_message(message)
      {
        "type" => "notification",
        "message" => message
      }
    end

end

