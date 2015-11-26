class GameState
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def units_on_territory(territory)
    Action.where(territory: territory).inject(0) { |total, action| total + action.units_difference }
  end

  def territory_owner(territory)
    Action.where(territory: territory).last.territory_owner
  end
end
