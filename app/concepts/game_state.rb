class GameState
  PLAYER_COLORS = %w{#4F2EC9 #63242E}

  attr_reader :game

  def initialize(game)
    @game = game
  end

  def player_color(player)
    PLAYER_COLORS[game.players.find_index(player)]
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

  def territory_links
    TerritoryLink.where(from_territory: game.territories).map do |link|
      [link.from_territory, link.to_territory]
    end
  end
end
