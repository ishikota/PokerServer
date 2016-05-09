class Broadcaster

  def initialize(server, room)
    @server = server
    @room = room
  end


  def notification(data)
    @server.broadcast "room:#{@room.id}", notification_message(data)
  end

  def ask(uuid, data)
    player = @room.players.find_by_uuid(uuid)
    @server.broadcast "room:#{@room.id}:#{player.id}", ask_message(data)
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
