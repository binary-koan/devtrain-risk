class PerformReinforce
  attr_reader :errors, :reinforce_event

  def initialize(game_state:, current_player:, reinforcements: nil, units_to_reinforce: nil)
    @game_state        = game_state
    @current_player    = current_player
    @reinforcements    = reinforcements || Reinforcement.new(current_player)
    @units_to_reinforce = units_to_reinforce || Reinforcement::MINIMUM_UNIT_COUNT
    @errors            = []
  end

  def call
    if player_has_no_territories?
      errors << :no_territories
    elsif !@game_state.can_reinforce?(@reinforcements.remaining_reinforcements)
      errors << :wrong_phase
    else
      reinforce_players_territories
    end

    @reinforce_event != nil
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
    if @units_to_reinforce != nil
      create_action(territory, @current_player, @units_to_reinforce)
    else
      create_action(territory, @current_player, @reinforcements.remaining_reinforcements)
    end
  end

  def create_reinforce_event
    Event.reinforce(game: @game_state.game, player: @current_player).tap do |event|
      event.save!
    end
  end

  def create_action(territory, territory_owner, units_difference)
    @reinforce_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
