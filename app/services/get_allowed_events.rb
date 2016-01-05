#TODO GET?? directory?
class GetAllowedEvents
  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending
  PHASE_FINISHED    = :finished

  Turn = Struct.new(:phase, :reinforcements, :fortified)

  def initialize(game_state, all_events)
    @game_state = game_state
    @events = events_in_current_turn(all_events)
    @player = game_state.current_player

    if game_state.won?
      @turn = Turn.new(PHASE_FINISHED)
    else
      @turn = Turn.new(PHASE_REINFORCING, Reinforcement.new(@player, @game_state), false)
    end
  end

  def call
    calculate_turn_state unless @turn.phase == PHASE_FINISHED

    [
      allowed_reinforce_event,
      allowed_attack_event,
      allowed_fortify_event,
      allowed_next_turn_event
    ].compact
  end

  private

  def events_in_current_turn(all_events)
    all_events.reverse.take_while { |event| !event.start_turn? }.reverse
  end

  def allowed_reinforce_event
    #TODO replace with shortcuts
    return unless @turn.phase == PHASE_REINFORCING && !@turn.reinforcements.none?

    @player.events.reinforce.new(action: Action::Add.new(
      units: @turn.reinforcements.remaining_units
    ))
  end

  def allowed_next_turn_event
    #TODO replace with shortcuts
    return if !(@turn.phase == PHASE_ATTACKING || @turn.phase == PHASE_ENDING) || territory_taken?

    @player.events.start_turn.new
  end

  def allowed_attack_event
    return if @turn.phase != PHASE_ATTACKING || territory_taken?

    @player.events.attack.new
  end

  def allowed_fortify_event
    return unless @turn.phase == PHASE_ATTACKING && !@turn.fortified

    if territory_taken?
      @player.events.fortify.new(action: Action::Move.new(
        territory_from: @events.last.action.territory_from,
        territory_to: @events.last.action.territory
      ))
    else
      @player.events.fortify.new
    end
  end

  def calculate_turn_state
    @events.inject(nil) do |previous_event, event|
      apply_event(event, previous_event)

      event
    end
  end

  def apply_event(event, previous_event)
    if event.reinforce?
      @turn.reinforcements.remove(event.action.units)
      @turn.phase = PHASE_ATTACKING if @turn.reinforcements.none?
    elsif event.attack?
      @turn.phase = PHASE_ATTACKING
    elsif event.fortify? && !fortifying_taken_territory?(event, previous_event)
      @turn.fortified = true
      @turn.phase = PHASE_ENDING
    end
  end

  def fortifying_taken_territory?(event, previous_event)
    return unless previous_event.present? && previous_event.attack?

    attack = previous_event.action

    attack.territory_from == event.action.territory_from && attack.territory == event.action.territory_to
  end

  def territory_taken?
    #TODO make a method
    @events.size > 0 &&
      @events.last.attack? && @game_state.units_on_territory(@events.last.action.territory) == 0
  end
end
