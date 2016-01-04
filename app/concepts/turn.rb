class Turn
  MINIMUM_REINFORCEMENTS = 1

  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending
  PHASE_FINISHED    = :finished

  attr_reader :reinforcements, :phase

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

  def can_reinforce?
    phase == PHASE_REINFORCING && !@reinforcements.none?
  end

  def can_attack?
    phase == PHASE_ATTACKING
  end

  def can_fortify?
    phase == PHASE_ATTACKING
  end

  def can_start_next_turn?
    phase == PHASE_ATTACKING || phase == PHASE_ENDING
  end

  def events
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

  private

  def previous_events
    @previous_turn.try!(:events) || []
  end

  #TODO also service
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
