class PlayerMaker

  def create(info, initial_stack)
    name = info["name"]
    PokerPlayer.new(name=name, initial_stack)
  end

end

