class RoomChannelDelegate

  def initialize(channel_wrapper, message_builder)
    @channel = channel_wrapper
    @message_builder = message_builder
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

    if room.filled_to_capacity?
      @channel.broadcast(room_id=room.id, @message_builder.build_start_poker_message)
      # TODO create dealer and start the game
    end
  end

  def exit_room(uuid)
    player = Player.find_by_uuid(uuid)
    @channel.broadcast(room_id=player.current_room.id, @message_builder.build_member_leave_message)
    player.clear_state
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

end

