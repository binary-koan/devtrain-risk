class DiceRoller
  attr_reader :rolls

  def initialize
    @rolls = []
  end

  def add_rolls(rolls)
    @rolls << rolls
  end
end
