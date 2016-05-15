class Broadcaster
  attr_accessor :ask_counter  # write for deserialize

  def initialize(server, room, ask_counter=0)
    @server = server
    @room = room
    @ask_counter = ask_counter
  end

  def notification(data)
    @server.broadcast "room:#{@room.id}", notification_message(data)
  end

  def ask(uuid, data)
    player = @room.players.find_by_uuid(uuid)
    @server.broadcast "room:#{@room.id}:#{player.id}", ask_message(data)
    @ask_counter += 1
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
        .merge!(counter: @ask_counter)
    end

end
