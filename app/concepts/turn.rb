class Turn
  MINIMUM_REINFORCEMENTS = 1

  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending

  attr_reader :events

  def initialize(events, previous_turn = nil)
    @events = events
    @previous_turn = previous_turn

    @phase = PHASE_REINFORCING
    @fortified = false

    @events.inject(nil) do |previous_event, event|
      apply_event(event, previous_event)
      event
    end
  end

  def ==(other)
    events == other.events
  end

  def player
    events.first.player
  end

  def game
    events.first.game
  end

  def reinforcements
    @reinforcements ||= Reinforcement.new(self)
  end

  def game_state
    @game_state ||= GameState.new(game, actions)
  end

  def can_reinforce?(unit_count = MINIMUM_REINFORCEMENTS)
    @phase == PHASE_REINFORCING && reinforcements.remaining?(unit_count)
  end

  def can_attack?
    @phase == PHASE_ATTACKING && !@fortified
  end

  alias_method :can_fortify?, :can_attack?

  def actions
    previous_actions = @previous_turn ? @previous_turn.actions : []
    previous_actions + @events.flat_map(&:actions)
  end

  private

  def apply_event(event, previous_event)
    if event.reinforce?
      reinforcements.remove(event.actions.first.units_difference)
      @phase = PHASE_ATTACKING if reinforcements.none?
    elsif event.attack?
      @phase = PHASE_ATTACKING
    elsif event.fortify? && !fortifying_attacked_territory?(event, previous_event)
      @fortified = true
      @phase = PHASE_ENDING
    end
  end

  def fortifying_attacked_territory?(fortify_event, attack_event)
    return unless territory_taken?(attack_event)

    source_territory(fortify_event) == source_territory(attack_event) &&
      target_territory(fortify_event) == target_territory(attack_event)
  end

  def territory_taken?(event)
    event.attack? && !event.actions.move_to.empty?
  end

  def source_territory(event)
    event.actions.move_from.first.territory
  end

  def target_territory(event)
    event.actions.move_to.first.territory
  end
end
