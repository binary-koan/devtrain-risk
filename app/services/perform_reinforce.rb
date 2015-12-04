class PerformReinforce
  attr_reader :errors, :reinforce_event

  def initialize(game_state:, territory:, units_to_reinforce:)
    @game_state         = game_state
    @territory          = territory
    @units_to_reinforce = units_to_reinforce
    @errors             = []
  end

  def call
    if player_has_no_territories?
      errors << :no_territories
      #TODO check @territory is owned by the player
    elsif !@game_state.can_reinforce?(@units_to_reinforce)
      errors << :wrong_phase
    else
      reinforce_players_territories
    end

    @reinforce_event.present?
  end

  private

  def player_has_no_territories?
    @game_state.owned_territories(@game_state.current_player).length == 0
  end

  def reinforce_players_territories
    @reinforce_event = create_reinforce_event
    create_action(@territory, @game_state.current_player, @units_to_reinforce)
  end

  def create_reinforce_event
    Event.reinforce(game: @game_state.game, player: @game_state.current_player).tap do |event|
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
