class GameState
  TerritoryInfo = Struct.new(:owner, :units)

  attr_reader :game, :territory_info

  def initialize(game, events)
    @game = game
    @territory_info = Hash.new { |hash, key| hash[key] = TerritoryInfo.new(nil, 0) }

    apply_events(events)
  end

  def won?
    winning_player.present?
  end

  def winning_player
    game.players.detect { |player| owned_territories(player).size == territory_info.size }
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

  private

  def apply_events(events)
    events.each do |event|
      case event.action
      when Action::Kill
        update_territory(event.action.territory, event.player, -event.action.units)
      when Action::Add
        update_territory(event.action.territory, event.player, event.action.units)
      when Action::Move
        update_territory(event.action.territory_from, event.player, -event.action.units)
        update_territory(event.action.territory_to, event.player, event.action.units)
      end
    end
  end

  def update_territory(territory, owner, units)
    @territory_info[territory].owner = owner
    @territory_info[territory].units += units
  end
end
