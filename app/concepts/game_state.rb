class GameState
  TerritoryInfo = Struct.new(:owner, :units)

  PLAYER_COLORS = %w{#4F2EC9 #63242E}

  #TODO territory_info is only public to make == work - is that OK?
  attr_reader :game, :territory_info

  def initialize(game, turns)
    @game = game
    @turns = turns
    @territory_info = Hash.new { |hash, key| hash[key] = TerritoryInfo.new(nil, 0) }

    turns.each { |turn| apply_actions(turn.actions) }
  end

  def ==(other)
    game == other.game && territory_info == other.territory_info
  end

  def current_player
    @turns.last.player
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

  def can_reinforce?(unit_count)
    @turns.last.can_reinforce?(unit_count)
  end

  def can_attack?
    @turns.last.can_attack?
  end

  def can_fortify?
    @turns.last.can_fortify?
  end

  private

  def apply_actions(actions)
    actions.each do |action|
      @territory_info[action.territory].owner = action.territory_owner
      @territory_info[action.territory].units += action.units_difference
    end
  end
end
