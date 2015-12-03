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
    true #TODO
    # @phase == PHASE_REINFORCING && @reinforcements.remaining >= unit_count
  end

  def can_attack?
    true #TODO
    # @phase == PHASE_ATTACKING && !@fortified
  end

  alias_method :can_fortify?, :can_attack?

  def apply_event(event)
    if event.reinforce?
      #TODO
      # @reinforcements.remove_units(event.actions.first.units_difference)
      # @turn_phase = PHASE_ATTACKING if @reinforcements.remaining == 0
    elsif event.attack?
      @turn_phase = PHASE_ATTACKING
    elsif event.fortify?
      @fortified = true
      @turn_phase = PHASE_ENDING
    end
  end
end
