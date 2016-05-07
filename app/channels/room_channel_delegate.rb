class RoomChannelDelegate

  def initialize(channel_wrapper)
    @channel = channel_wrapper
  end

  def enter_room(data)
    room = fetch_room(data)
    player = fetch_player(data)
    player.take_a_seat(room)

    @channel.subscribe(room_id=room.id)
    @channel.subscribe(room_id=room.id, player_id=player.id)

    @channel.broadcast(room_id=room.id, "arrive msg")
    @channel.broadcast(room_id=room.id, player_id=player.id, "welcome msg")

    if room.filled_to_capacity?
      @channel.broadcast(room_id=room.id, "start poker msg")
      # TODO create dealer and start the game
    end
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

