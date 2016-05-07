class DataFormatter

  def initialize(game_evaluator)
    @game_evaluator = game_evaluator
  end

  def format_player(player, holecard=false)
    hash = JSON.parse(player.to_json)
    hash.delete("action_histories")
    hash.delete("hole_card")
    hash.delete("pay_info")
    hash.merge!( { "state" => player.pay_info.status } )
    hash.merge!( { "hole_card" => format_cards(player.hole_card) } ) if holecard
    return hash
  end

  def format_seats(seats)
    { "seats" => format_players(seats.players) }
  end

  def format_pot(players)
    pots = @game_evaluator.create_pot(players)
    main = { "amount" => pots.first[:amount] }
    side = pots.drop(1).map { |side_pot|
      new_hash = {}
      new_hash.merge!( { "amount" => side_pot[:amount] } )
      new_hash.merge!( { "eligibles" => format_players(side_pot[:eligibles]) } )
    }

    { "main" => main, "side" => side }
  end


  def format_game_information(config, seats)
    hash = {}
    hash.merge!( { "player_num" => seats.players.size } )
    hash.merge!( { "seats" => format_seats(seats) } )
    hash.merge!( { "rule" => format_config(config) } )
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

  def format_action_histories(table)
    { "action_histories" => order_histories(table.dealer_btn, table.seats.players) }
  end

  def format_winners(winners)
    { "winners" => format_players(winners) }
  end

  def format_round_state(round_manager, table)
    next_player_pos = round_manager.next_player
    next_player = table.seats.players[next_player_pos]

    {}.merge!(fetch_round_info(round_manager))
      .merge!(fetch_table_info(table))
      .merge!( { "next_player" => format_player(next_player) } )
  end

  private

    def order_histories(next_player_pos, players)
      deep_copy = lambda { |ary| ary.map { |e| e } }

      ordered_histories = []
      histories = players.map { |player| deep_copy.call(player.action_histories) }
      begin
        history = histories[next_player_pos].shift
        history.merge!( { "player" => format_player(players[next_player_pos]) } ) unless history.nil?
        ordered_histories << history
        next_player_pos = (next_player_pos + 1) % players.size
      end until histories.flatten.empty?
      ordered_histories.select { |history| not history.nil? }
    end

    def format_players(players)
      players.map { |player| format_player(player) }
    end

    def format_cards(cards)
      cards.map {|c| c.to_s }
    end

    def format_config(config)
      JSON.parse(config.to_json)
    end

    def fetch_round_info(round_manager)
      {
        "street" => RoundManager::STREET_MAP[round_manager.street]
      }
    end

    def fetch_table_info(table)
      {}.merge!( { "dealer_btn" => table.dealer_btn } )
        .merge!( { "community_card" => format_cards(table.community_card.cards) } )
        .merge!( { "seats" => format_seats(table.seats) } )
        .merge!( { "pot" => format_pot(table.seats.players) } )
    end

end

