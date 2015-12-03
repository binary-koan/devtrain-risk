class Turn
  PHASE_REINFORCING = :reinforcing
  PHASE_ATTACKING   = :attacking
  PHASE_ENDING      = :ending

  attr_reader :player

  def initialize(player)
    @player = player
    @phase = PHASE_REINFORCING
    @reinforcements = Reinforcement.new
    @fortified = false
  end

  def can_reinforce?(unit_count)
    @phase == PHASE_REINFORCING && @reinforcements.remaining_reinforcements >= unit_count
  end

  def can_attack?
    @phase == PHASE_ATTACKING && !@fortified
  end

  alias_method :can_fortify?, :can_attack?

  def apply_event(event)
    if event.reinforce?
      @reinforcements.remove_units(event.actions.first.units_difference)
      @phase = PHASE_ATTACKING if @reinforcements.remaining_reinforcements == 0
    elsif event.attack?
      @phase = PHASE_ATTACKING
    elsif event.fortify?
      @fortified = true
      @phase = PHASE_ENDING
    end
  end
end
