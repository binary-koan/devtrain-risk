class GameState
  TerritoryInfo = Struct.new(:owner, :units)

  PLAYER_COLORS = %w{#4F2EC9 #63242E}

  attr_reader :game

  def self.current(game)
    new(game).tap { |state| state.apply_events(game.events) }
  end

  def initialize(game)
    @game = game
    @territory_info = Hash.new { |hash, key| hash[key] = TerritoryInfo.new(nil, 0) }
  end

  def apply_events(events)
    events.each { |event| apply_event(event) }
  end

  def player_color(player)
    PLAYER_COLORS[game.players.find_index(player)]
  end

  def won?
    winning_player != nil
  end

  def winning_player
    @game.players.detect { |player| owned_territories(player).size == @territory_info.size }
  end

  def current_player
    @current_player
  end

  def owned_territories(player)
    @territory_info.select { |territory, info| info.owner == player }.map(&:first)
  end

  def territory_owner(territory)
    @territory_info[territory].owner
  end

  def units_on_territory(territory)
    @territory_info[territory].units
  end

  def territory_links
    TerritoryLink.where(from_territory: game.territories).map do |link|
      [link.from_territory, link.to_territory]
    end
  end

  private

  def apply_event(event)
    if event.start_turn?
      @current_player = event.player
    end

    event.actions.each do |action|
      @territory_info[action.territory].owner = action.territory_owner
      @territory_info[action.territory].units += action.units_difference
    end
  end
end
