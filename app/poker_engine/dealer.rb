class Dealer

  def initialize(components_holder)
    @broadcaster = components_holder[:broadcaster]
    @config = components_holder[:config]
    @table = components_holder[:table]
    @round_manager = components_holder[:round_manager]
    @action_checker = components_holder[:action_checker]
    @player_maker = components_holder[:player_maker]
    @round_count = 0
  end

  def start_game(player_info)
    players = player_info.map { |info| create_player(info) }

    set_player_to_seat(players)

    @broadcaster.notification(game_information_message)

    start_round

    # notify game start
  end


  # private

    def start_round
      @round_manager.start_new_round(@table)
    end

    def create_player(info)
      @player_maker.create(@config.initial_stack) #TODO use passed info
    end

    def set_player_to_seat(players)
      for player in players
        @table.seats.sitdown(player)
      end
    end

    def game_information_message
      "TODO game info"
    end


end

