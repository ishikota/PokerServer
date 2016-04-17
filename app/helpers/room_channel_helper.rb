module RoomChannelHelper

  def generate_arrival_message(room, player)
    need_player_num = room.player_num - room.players.size
    "player [#{player.name}] arrived!!\
    #{need_player_num} more players are needed to start the game."
  end

end
