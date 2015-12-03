class Reinforcement
  MINIMUM_UNIT_COUNT = 3

  attr_reader :remaining_reinforcements

  def initialize(player = nil)
    @player = player
    @remaining_reinforcements = calculate_reinforcement_count
  end

  private

  def calculate_reinforcement_count
    MINIMUM_UNIT_COUNT
  end
end
