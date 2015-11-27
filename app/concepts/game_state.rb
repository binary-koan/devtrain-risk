class GameState
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def owned_territories(player)
    game.territories.select do |territory|
      territory_owner(territory) == player
    end
  end

  def territory_owner(territory)
    Action.where(territory: territory).last.territory_owner
  end

  def units_on_territory(territory)
    Action.where(territory: territory).inject(0) { |total, action| total + action.units_difference }
  end
end
