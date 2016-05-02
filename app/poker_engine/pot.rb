class Pot
  attr_reader :main

  def initialize
    @main = 0
  end

  def add_chip(amount)
    @main += amount
  end

  def clear
    @main = 0
  end

end

