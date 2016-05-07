class ChannelWrapper

  def initialize(channel)
    @channel = channel
  end

  def subscribe(room_id, player_id=nil)
    channel = generate_channel(room_id, player_id)
    @channel.stream_from channel
  end

  def broadcast(room_id, player_id=nil, message)
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

