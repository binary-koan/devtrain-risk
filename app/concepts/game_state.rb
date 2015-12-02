class GameState
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def player_won?(player)
    owned_territories_count = owned_territories(player).size
    player if game.territories.count == owned_territories_count && owned_territories_count > 1
  end

  def current_player
    @game.events.where(event_type: "start_turn").last.player
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
