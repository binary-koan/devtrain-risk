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
    elsif !can_reinforce?
      errors << :cannot_reinforce
    elsif !enough_reinforcing_units?
      errors << :too_few_reinforcing_units
    else
      reinforce_territory!
    end

    @reinforce_event.present?
  end

  private

  def territory_owned_by_player?
    @turn.player == @turn.game_state.territory_owner(@territory)
  end

  def can_reinforce?
    allowed_events = GetAllowedEvents.new(@turn).call
    reinforce_event = allowed_events.detect(&:reinforce?)

    reinforce_event.present? && @units_to_reinforce <= reinforce_event.action.units
  end

  def enough_reinforcing_units?
    @units_to_reinforce > 0
  end

  def reinforce_territory!
    ActiveRecord::Base.transaction do
      @reinforce_event = create_reinforce_event!(create_action!)
    end
  end

  def create_reinforce_event!(action)
    @turn.player.events.reinforce.create!(action: action)
  end

  def create_action!
    Action::Add.create!(territory: @territory, units: @units_to_reinforce)
  end
end
