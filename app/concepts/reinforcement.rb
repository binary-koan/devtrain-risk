class Reinforcement
  MINIMUM_UNIT_COUNT = 3

  def initialize(unit_count = nil)
    @unit_count = unit_count || MINIMUM_UNIT_COUNT
  end

  def all_units
    units = @unit_count
    @unit_count = 0
    units
  end
end
