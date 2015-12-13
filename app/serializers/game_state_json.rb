class GameStateJson
  def initialize(turn)
    @turn = turn
    @game = turn.game
  end

  def json
    {
      territories: territories,
      territoryLinks: territory_links,
      players: @game.players.select("id, name"),
      currentPlayer: @game.players.find_index(@turn.player),
      winningPlayer: @turn.game_state.winning_player
    }
  end

  private

  def territories
    indexes = ids_to_indexes(@game.players)

    @game.territories.map do |territory|
      {
        id: territory.id,
        name: territory.name,
        x: territory.x,
        y: territory.y,
        units: @turn.game_state.units_on_territory(territory),
        owner: indexes[@turn.game_state.territory_owner(territory).id]
      }
    end
  end

  def territory_links
    indexes = ids_to_indexes(@game.territories)

    TerritoryLink.where(from_territory: @game.territories).map do |link|
      { from: indexes[link.from_territory.id], to: indexes[link.to_territory.id] }
    end
  end

  def ids_to_indexes(model)
    Hash[model.pluck(:id).each.with_index.to_a]
  end
end
