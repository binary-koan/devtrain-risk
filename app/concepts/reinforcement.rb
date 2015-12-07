class Reinforcement
  MINIMUM_UNIT_COUNT = 3

  attr_reader :remaining_units

  def initialize(player, game_state)
    @player = player
    @game_state = game_state
    @remaining_units = calculate_reinforcement_count
  end

  def remove(units_to_remove)
    if units_to_remove <= remaining_units
      @remaining_units -= units_to_remove
    end
  end

  def remaining?(count)
    remaining_units >= count
  end

  def none?
    remaining_units == 0
  end

  private

  def calculate_reinforcement_count
    [@game_state.owned_territories(@player).size, MINIMUM_UNIT_COUNT].max
  end
end
