class Turn
  MINIMUM_REINFORCEMENTS = 1

  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending

  def initialize(events_in_turn, previous_turn = nil)
    @events_in_turn = events_in_turn
    @previous_turn = previous_turn

    @phase = PHASE_REINFORCING
    @fortified = false

    @events_in_turn.inject(nil) do |previous_event, event|
      apply_event(event, previous_event)
      event
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

  def reinforcements
    @reinforcements ||= Reinforcement.new(self)
  end

  def game_state
    @game_state ||= GameState.new(game, events)
  end

  def allowed_events
    if @phase == PHASE_REINFORCING
      [player.events.reinforce.new]
    elsif @phase == PHASE_ATTACKING
      [player.events.attack.new, player.events.fortify.new, player.events.start_turn.new]
    elsif @phase == PHASE_ENDING
      [player.events.start_turn.new]
    end
  end

  def can_reinforce?(unit_count = MINIMUM_REINFORCEMENTS)
    @phase == PHASE_REINFORCING && reinforcements.remaining?(unit_count)
  end

  def can_attack?
    @phase == PHASE_ATTACKING && !@fortified
  end

  alias_method :can_fortify?, :can_attack?

  private

  def apply_event(event, previous_event)
    if event.reinforce?
      reinforcements.remove(event.action.units)
      @phase = PHASE_ATTACKING if reinforcements.none?
    elsif event.attack?
      @phase = PHASE_ATTACKING
    elsif event.fortify?
      @fortified = true
      @phase = PHASE_ENDING
    end
  end
end
