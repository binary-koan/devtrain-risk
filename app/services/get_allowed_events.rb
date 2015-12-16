class GetAllowedEvents
  def initialize(turn)
    @turn = turn
    @player = turn.player
  end

  def call
    [
      allowed_reinforce_event,
      allowed_attack_event,
      allowed_fortify_event,
      allowed_next_turn_event
    ].compact
  end

  private

  def allowed_reinforce_event
    return unless @turn.can_reinforce?

    @player.events.reinforce.new(action: Action::Add.new(
      units: @turn.reinforcements.remaining_units
    ))
  end

  def allowed_next_turn_event
    return if !@turn.can_start_next_turn? || territory_taken?

    @player.events.start_turn.new
  end

  def allowed_attack_event
    return if !@turn.can_attack? || territory_taken?

    @player.events.attack.new
  end

  def allowed_fortify_event
    return unless @turn.can_fortify?

    if territory_taken?
      @player.events.fortify.new(action: Action::Move.new(
        territory_from: @turn.events.last.action.territory_from,
        territory_to: @turn.events.last.action.territory
      ))
    else
      @player.events.fortify.new
    end
  end

  def territory_taken?
    takeover_event = @turn.events.last

    takeover_event.attack? && @turn.game_state.units_on_territory(takeover_event.action.territory) == 0
  end
end
