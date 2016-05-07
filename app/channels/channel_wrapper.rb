class ChannelWrapper

  def subscribe(room_id, player_id)
    channel = generate_channel(room_id, player_id)
    stream_from channel
  end

  def broadcast(room_id, player_id, message)
    channel = generate_channel(room_id, player_id)
    ActionCable.server.broadcast channel, message
  end

  # public for test
  def generate_channel(room_id, player_id=nil)
    channel = "room:#{room_id}"
    channel << ":#{player_id}" unless player_id.nil?
    return channel
  end

end

