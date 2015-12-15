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
    calculated_count = @game_state.owned_territories(@player).size + continent_bonus

    [calculated_count, MINIMUM_UNIT_COUNT].max
  end

  def continent_bonus #TODO why you no make this code look nice??
    continents = Hash.new
    bonus = 0
    @game_state.game.continents.each { |c| continents[c] = [] }

    @game_state.game.territories.each do |territory|
      continents[territory.continent] << territory
    end

    continents.each do |continent, territories|
      bonus += territories.size if territories.all? { |territory| @game_state.territory_owner(territory) == @player }
    end

    bonus
  end
end
