class Turn
  MINIMUM_REINFORCEMENTS = 1

  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending

  attr_reader :events, :reinforcements

  def initialize(events, previous_turn = nil)
    @events = events
    @previous_turn = previous_turn

    @phase = PHASE_REINFORCING
    @reinforcements = Reinforcement.new(self)
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
    @game_state ||= GameState.new(game, actions)
  end

  def can_reinforce?(unit_count = MINIMUM_REINFORCEMENTS)
    @phase == PHASE_REINFORCING && @reinforcements.remaining?(unit_count)
  end

  def can_attack?
    @phase == PHASE_ATTACKING && !@fortified
  end

  alias_method :can_fortify?, :can_attack?

  def actions
    previous_actions = @previous_turn ? @previous_turn.actions : []
    previous_actions + @events.map(&:actions).flatten
  end

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
