class PerformReinforce
  attr_reader :errors, :reinforce_event

  def initialize(turn:, territory:, units_to_reinforce:)
    @turn               = turn
    @territory          = territory
    @units_to_reinforce = units_to_reinforce
    @errors             = []
  end

  def call
    if !territory_owned_by_player?
      errors << :reinforcing_enemy_territory
    elsif !@turn.can_reinforce?(@units_to_reinforce)
      errors << :cannot_reinforce
    else
      reinforce_players_territories
    end

    @reinforce_event.present?
  end

  private

  def territory_owned_by_player?
    @turn.player == @turn.game_state.territory_owner(@territory)
  end

  def reinforce_players_territories
    ActiveRecord::Base.transaction do
      @reinforce_event = create_reinforce_event!
      create_action!(@territory, @turn.player, @units_to_reinforce)
    end
  end

  def create_reinforce_event!
    Event.reinforce(game: @turn.game, player: @turn.player).tap do |event|
      event.save!
    end
  end

  def create_action!(territory, territory_owner, units_difference)
    @reinforce_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
