class PerformReinforce
  REINFORCEMENT_UNIT_COUNT = 3 #TODO refactor into separate object

  attr_reader :errors

  def initialize(game_state:, current_player:)
    @game_state     = game_state
    @current_player = current_player
    @errors         = []
  end

  def call
    if player_has_no_territories?
      errors << :no_territories
    else
      reinforce_players_territories
    end

    @reinforce_event
  end

  private

  def player_has_no_territories?
    @game_state.owned_territories(@current_player).length == 0
  end

  def reinforce_players_territories
    @reinforce_event = create_reinforce_event
    territory = find_random_territory
    reinforce_territory(territory)
  end

  def find_random_territory
    territories = @game_state.game.territories.select do |territory|
      @game_state.territory_owner(territory) == @current_player
    end
    territories.sample
  end

  def reinforce_territory(territory)
    create_action(territory, @current_player, REINFORCEMENT_UNIT_COUNT)
  end

  def create_reinforce_event
    Event.create!(
      event_type: "reinforce",
      game: @game_state.game,
      player: @current_player
    )
  end

  def create_action(territory, territory_owner, units_difference)
    @reinforce_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
