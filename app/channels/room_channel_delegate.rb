class RoomChannelDelegate

  def initialize(channel_wrapper, message_builder, dealer_maker)
    @channel = channel_wrapper
    @message_builder = message_builder
    @dealer_maker = dealer_maker
  end

  def enter_room(uuid, data)
    room = fetch_room(data)
    player = fetch_player(data)
    player.take_a_seat(room)
    player.update_attributes(uuid: uuid)

    @channel.subscribe(room_id=room.id)
    @channel.subscribe(room_id=room.id, player_id=player.id)

    @channel.broadcast(room_id=room.id, @message_builder.build_member_arrival_message(room, player))
    @channel.broadcast(room_id=room.id, player_id=player.id, @message_builder.build_welcome_message)
  end

  def exit_room(uuid)
    player = Player.find_by_uuid(uuid)
    room = player.current_room
    unless room.nil?
      message = @message_builder.build_member_leave_message(room, player)
      @channel.broadcast(room_id=player.current_room.id, @message_builder.build_member_leave_message(room, player)) unless room.nil?
    end
    player.clear_state
    room.clear_state if room.players.empty?
  end

  def connection_check(uuid)
    player = Player.find_by_uuid(uuid)
    room = player.current_room
    player.update(online: true) unless player.online?

    if room.filled_to_capacity? && room.everyone_online? && room.game_state.nil?
      @channel.broadcast(room_id=room.id, @message_builder.build_start_poker_message)
      dealer = @dealer_maker.create(room)
      msgs = dealer.start_game(players_info(room))
      game_state = GameState.create(state: dealer.serialize)
      GameStateRelationship.create(room_id: room.id, game_state_id: game_state.id)
      broadcast_dealer_message(room.reload, msgs)
    end
  end

  def declare_action(uuid, data)
    room = fetch_room(data)
    player = fetch_player(data)
    dealer = fetch_dealer(room)

    msgs = dealer.receive_data(player.uuid, data)
    broadcast_dealer_message(room, msgs)
    room.game_state.update(state: dealer.serialize)
    message = @message_builder.build_action_accept_message
    @channel.broadcast(room_id=room.id, player_id=player.id, message)
  end



  private

    def fetch_room(data)
      room_id = data["room_id"]
      Room.find(room_id)
    end

    def fetch_player(data)
      player_id = data["player_id"]
      Player.find(player_id)
    end

    def fetch_dealer(room)
      components_holder = @dealer_maker.setup_components_holder(room)
      Dealer.deserialize(components_holder, room.game_state.state)
    end

    def players_info(room)
      room.players.reduce([]) { |ary, player|
        ary << { "name" => player.name, "uuid" => player.uuid }
      }
    end

    def broadcast_dealer_message(room, messages)
      messages.each { |msg|
        if msg["type"] == "notification"
          @channel.broadcast(room_id=room.id, notification_message(msg["message"]))
        elsif msg["type"] == "ask"
          recipient = Player.find_by_uuid(msg["recipient"])
          message = ask_message(msg["message"], room.game_state.ask_counter)
          @channel.broadcast(room_id=room.id, player_id=recipient.id, message)
          room.game_state.increment!(:ask_counter)
        end
      }
    end

    def notification_message(data)
      {}.merge!(phase: "play_poker")\
        .merge!(type: "notification")\
        .merge!(message: data)
    end

    def ask_message(data, ask_counter)
      {}.merge!(phase: "play_poker")\
        .merge!(type: "ask")\
        .merge!(message: data)
        .merge!(counter: ask_counter)
    end

end

