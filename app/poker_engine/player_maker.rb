class PlayerMaker

  def create(name, initial_stack)
    PokerPlayer.new(name=name, initial_stack)
  end

end

