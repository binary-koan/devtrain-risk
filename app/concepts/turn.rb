class Turn
  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending

  attr_reader :events, :reinforcements

  def initialize(events, previous_turn = nil)
    @events = events
    @previous_turn = previous_turn

    @phase = PHASE_REINFORCING
    @reinforcements = Reinforcement.new(events.first.player, game_state)
    @fortified = false

    @events.each { |event| apply_event(event) }
  end

  def ==(other)
    @events == other.events
  end

  def player
    @events.first.player
  end

  def game
    @events.first.game
  end

  def game_state
    @game_state ||= GameState.new(@events.first.game, actions)
  end

  def actions
    previous_actions = @previous_turn ? @previous_turn.actions : []
    @events.map(&:actions).flatten + previous_actions
  end

  def reinforcements_available
    @reinforcements.remaining_units
  end

  def can_reinforce?(unit_count)
    @phase == PHASE_REINFORCING && @reinforcements.remaining?(unit_count)
  end

  def can_attack?
    @phase == PHASE_ATTACKING && !@fortified
  end

  alias_method :can_fortify?, :can_attack?

  private

  def apply_event(event)
    if event.reinforce?
      @reinforcements.remove(event.actions.first.units_difference)
      @phase = PHASE_ATTACKING if @reinforcements.none?
    elsif event.attack?
      @phase = PHASE_ATTACKING
    elsif event.fortify?
      @fortified = true
      @phase = PHASE_ENDING
    end
  end
end
