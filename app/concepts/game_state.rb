class GameState
  attr_reader :game

  def initialize(game)
    @game = game
  end

  def players
    players_by_id = Hash[game.players.map { |p| [p.id, { name: p.name }] }]
  end

  def territories
    territories_by_id = Hash[game.territories.map { |t| [t.id, { units: 0 }] }]
    game.events.each do |event|
      event.actions.each do |action|
        territory = territories_by_id[action.territory.id]
        territory[:units] += action.units_difference
        territory[:owner] = action.territory_owner.id
      end
    end
    territories_by_id
  end

  def territory_links
    TerritoryLink.where(from_territory: game.territories).map do |link|
      { from: link.from_territory.id, to: link.to_territory.id }
    end
  end

  def find_number_of_units(territory)
    Action.where(territory: territory).inject(0) do |total, action|
      total + action.units_difference
    end
  end
end
