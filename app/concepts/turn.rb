class Turn
  MINIMUM_REINFORCEMENTS = 1

  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending
  PHASE_FINISHED    = :finished

  def initialize(events_in_turn, previous_turn = nil)
    @events_in_turn = events_in_turn
    @previous_turn = previous_turn

    @phase = PHASE_REINFORCING
    @reinforcements = Reinforcement.new(player, game_state)
    @fortified = false

    @events_in_turn.inject(nil) do |previous_event, event|
      apply_event(event, previous_event)
      event
    end

    if game_state.won?
      @phase = PHASE_FINISHED
    end
  end

  def events
    previous_events = @previous_turn.present? ? @previous_turn.events : []
    previous_events + @events_in_turn
  end

  def ==(other)
    events == other.events
  end

  def player
    @events_in_turn.first.player
  end

  def game
    @events_in_turn.first.game
  end

  def game_state
    @game_state ||= GameState.new(game, events)
  end

  def allowed_events
    [
      allowed_reinforce_event,
      allowed_attack_event,
      allowed_fortify_event,
      allowed_end_turn_event
    ].compact
  end

  def can_reinforce?(unit_count = MINIMUM_REINFORCEMENTS)
    reinforce_event = allowed_reinforce_event
    reinforce_event.present? && unit_count <= reinforce_event.action.units
  end

  def can_attack?
    allowed_attack_event.present?
  end

  #TODO eww
  def can_fortify?(territory_from, territory_to)
    fortify_event = allowed_fortify_event

    if !fortify_event.present?
      false
    elsif fortify_event.action
      fortify_event.action.territory_from == territory_from &&
        fortify_event.action.territory_to == territory_to
    else
      true
    end
  end

  def can_end_turn?
    allowed_end_turn_event.present?
  end

  private

  def allowed_reinforce_event
    return unless @phase == PHASE_REINFORCING && !@reinforcements.none?

    player.events.reinforce.new(action: Action::Add.new(
      units: @reinforcements.remaining_units
    ))
  end

  def allowed_end_turn_event
    return unless (@phase == PHASE_ATTACKING || @phase == PHASE_ENDING) && !territory_taken?

    player.events.start_turn.new
  end

  def allowed_attack_event
    return unless @phase == PHASE_ATTACKING && !territory_taken?

    player.events.attack.new
  end

  def allowed_fortify_event
    return unless @phase == PHASE_ATTACKING

    if territory_taken?
      player.events.fortify.new(action: Action::Move.new(
        territory_from: events.last.action.territory_from,
        territory_to: events.last.action.territory
      ))
    else
      player.events.fortify.new
    end
  end

  def territory_taken?
    events.last.attack? && game_state.units_on_territory(events.last.action.territory) == 0
  end

  def apply_event(event, previous_event)
    if event.reinforce?
      @reinforcements.remove(event.action.units)
      @phase = PHASE_ATTACKING if @reinforcements.none?
    elsif event.attack?
      @phase = PHASE_ATTACKING
    elsif event.fortify? && !fortifying_after_attack?(event, previous_event)
      @fortified = true
      @phase = PHASE_ENDING
    end
  end

  def fortifying_after_attack?(event, previous_event)
    return unless previous_event.attack?

    attack = previous_event.action

    attack.territory_from == event.action.territory_from && attack.territory == event.action.territory_to
  end
end
