class Broadcaster

  def initialize(server, room)
    @server = server
    @room_id = room.id
  end


  def notification(data)
    @server.broadcast "room:#{@room_id}", notification_message(data)
  end

  def ask(player_id, data)
    @server.broadcast "room:#{@room_id}:#{player_id}", ask_message(data)
  end


  private

    def notification_message(data)
      {}.merge!(phase: "play_poker")\
        .merge!(type: "notification")\
        .merge!(message: data)
    end

    def ask_message(data)
      {}.merge!(phase: "play_poker")\
        .merge!(type: "ask")\
        .merge!(message: data)
    end

end
