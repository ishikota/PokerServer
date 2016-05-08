class PlayerMaker

  def create(info, initial_stack)
    name = info["name"]
    uuid = info["uuid"]
    raise "uuid is not found in player information" if uuid.nil?
    PokerPlayer.new(name=name, uuid, initial_stack)
  end

end

