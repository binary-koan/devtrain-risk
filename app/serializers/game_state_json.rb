class GameStateJson
  def initialize(game_state)
    @game_state = game_state
    @game = game_state.game
  end

  def territories
    indexes = ids_to_indexes(@game.players)

    @game.territories.map do |territory|
      {
        units: @game_state.units_on_territory(territory),
        owner: indexes[@game_state.territory_owner(territory).id]
      }
    end
  end

  def territory_links
    indexes = ids_to_indexes(@game.territories)

    TerritoryLink.where(from_territory: @game.territories).map do |link|
      { source: indexes[link.from_territory.id], target: indexes[link.to_territory.id] }
    end
  end

  def players
    @game.players.select("id, name").to_a.map(&:serializable_hash)
  end

  private

  def ids_to_indexes(model)
    Hash[model.pluck(:id).each.with_index.to_a]
  end
end
