class Reinforcement
  MINIMUM_UNIT_COUNT = 3

  attr_reader :remaining_units

  def initialize(turn)
    @turn = turn
    @remaining_units = calculate_reinforcement_count
  end

  def remove(units_to_remove)
    if units_to_remove <= remaining_units
      @remaining_units -= units_to_remove
      true
    else
      false
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
    calculated_count = @turn.game_state.owned_territories(@turn.player).size

    [calculated_count, MINIMUM_UNIT_COUNT].max
  end
end
