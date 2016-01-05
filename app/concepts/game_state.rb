class GameState
  TerritoryInfo = Struct.new(:owner, :units)

  attr_reader :game, :territory_info
  attr_accessor :current_player

  def initialize(game)
    @game = game
    @territory_info = Hash.new { |hash, key| hash[key] = TerritoryInfo.new(nil, 0) }
  end

  def update_territory(territory, owner, units_difference)
    @territory_info[territory].owner = owner
    @territory_info[territory].units += units_difference
  end

  def won?
    winning_player.present?
  end

  def winning_player
    game.players.detect { |player| owned_territories(player).size == territory_info.size }
  end

  def in_game?(player)
    owned_territories(player).size > 0
  end

  def owned_territories(player)
    territory_info.select { |territory, info| info.owner == player }.map(&:first)
  end

  def territory_owner(territory)
    territory_info[territory].owner
  end

  def units_on_territory(territory)
    territory_info[territory].units
  end

  def territory_links
    TerritoryLink.where(from_territory: game.territories).map do |link|
      [link.from_territory, link.to_territory]
    end
  end
end
