class RoomChannelDelegate
  include RoomChannelDelegateHelper

  def initialize(channel_wrapper, message_builder)
    @channel = channel_wrapper
    @message_builder = message_builder
    @dealer_hash = {}
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
      dealer = Dealer.new(setup_components_holder(room))
      @dealer_hash.merge!( { room.id => dealer } )
      dealer.start_game(players_info(room))
    end
  end

  def exit_room(uuid)
    player = Player.find_by_uuid(uuid)
    room = player.current_room
    unless room.nil?
      message = @message_builder.build_member_leave_message(room, player)
      @channel.broadcast(room_id=player.current_room.id, @message_builder.build_member_leave_message(room, player)) unless room.nil?
    end
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

    def players_info(room)
      room.players.reduce([]) { |ary, player|
        ary << { "name" => player.name }
      }
    end

end

