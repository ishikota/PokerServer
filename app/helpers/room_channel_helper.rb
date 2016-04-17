module RoomChannelHelper

  def generate_arrival_message(room, player)
    need_player_num = room.player_num - room.players.size
    "player [#{player.name}] arrived!!\
    #{need_player_num} more players are needed to start the game."
  end

  def generate_leave_message(room, player)
    need_player_num = room.player_num - room.players.size
    "player [#{player.name}] left the room ...\
    #{need_player_num} more players are needed to start the game."
  end

  #TODO add game rule in game info
  def generate_game_info(room)
    players = room.players.inject(""){ |acc, p| acc << "  id : #{p.id}, name : #{p.name}\n" }
    "======================================\n"+
    "[Game Information]\n"+
    "Room name : #{room.name}\n"+
    "Round     : #{room.max_round} round\n"+
    "player    : #{room.player_num} player\n"+
    "#{players}"+
    "======================================\n"
  end

end
