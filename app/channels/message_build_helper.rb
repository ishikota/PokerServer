class MessageBuildHelper

  module Phase
    MEMBER_WANTED = "member_wanted"
  end

  module Type
    WELCOME = "welcome"
    MEMBER_ARRIVAL = "arrival"
  end


  def build_welcome_message
    {}.merge(phase: Phase::MEMBER_WANTED)
      .merge(type: Type::WELCOME)
  end

  def build_member_arrival_message(room, player)
    {}.merge(phase: Phase::MEMBER_WANTED)
      .merge(type: Type::MEMBER_ARRIVAL)
      .merge(message: member_arrival_message(room, player))
  end

  private

    def member_arrival_message(room, player)
      need_player_num = room.player_num - room.players.size
      "player [#{player.name}] arrived!!\
      #{need_player_num} more players are needed to start the game."
    end


end

