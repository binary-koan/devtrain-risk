class PerformAttack
  #TODO break this service up
  MIN_UNITS_ON_TERRITORY = 1
  MIN_ATTACKING_UNITS    = 1
  MAX_ATTACKING_UNITS    = 3
  MAX_DEFENDING_UNITS    = 2

  DICE_RANGE = 1..6

  attr_reader :errors, :attack_event

  def initialize(territory_from:, territory_to:, turn:, attacking_units:)
    @territory_from  = territory_from
    @territory_to    = territory_to
    @turn            = turn
    @attacking_units = attacking_units
    @errors          = []
  end

  def call
    if !valid_link?
      errors << :no_link
    elsif !current_players_territory?
      errors << :wrong_player
    elsif !@turn.can_attack?
      errors << :wrong_phase
    elsif !attacking_different_player?
      errors << :own_territory
    else
      perform_attack
    end

    @attack_event.present?
  end

  private

  def valid_link?
    @territory_from.connected_territories.include?(@territory_to)
  end

  def current_players_territory?
    find_owner(@territory_from) == @turn.player
  end

  def attacking_different_player?
    find_owner(@territory_from) != find_owner(@territory_to)
  end

  def find_owner(territory)
    @turn.game_state.territory_owner(territory)
  end

  def perform_attack
    if too_few_available_attackers?
      errors << :too_few_available_attackers
    elsif too_many_units?
      errors << :too_many_units
    elsif too_few_units?
      errors << :too_few_units
    else
      ActiveRecord::Base.transaction do
        @attack_event = create_attack_event!

        create_attack_actions!(dice_rolls_for_units)
      end
    end
  end

  def too_few_available_attackers?
    available_attackers < MIN_ATTACKING_UNITS
  end

  def too_many_units?
    #TODO combine these two into method
    @attacking_units > MAX_ATTACKING_UNITS || @attacking_units > available_attackers
  end

  def too_few_units?
    @attacking_units < MIN_ATTACKING_UNITS
  end

  def create_attack_event!
    from_territory_owner.events.attack.create!
  end

  def create_attack_actions!(paired_rolls)
    defenders_lost, attackers_lost = attack_result(paired_rolls)

    if territory_taken?(defenders_lost)
      take_over_territory!(defenders_lost, paired_rolls.length)
    else
      create_action!(@territory_to, find_owner(@territory_to), -defenders_lost) if defenders_lost > 0
      create_action!(@territory_from, find_owner(@territory_from), -attackers_lost) if attackers_lost > 0
    end
  end

  def territory_taken?(defenders_lost)
    remaining_defenders = @turn.game_state.units_on_territory(@territory_to)

    defenders_lost == remaining_defenders
  end

  def from_territory_owner
    @turn.game_state.territory_owner(@territory_from)
  end

  def available_attackers
    units = @turn.game_state.units_on_territory(@territory_from) - MIN_UNITS_ON_TERRITORY
    [units, MAX_ATTACKING_UNITS].min
  end

  def number_of_defenders
    units = @turn.game_state.units_on_territory(@territory_to)
    [units, MAX_DEFENDING_UNITS].min
  end

  def dice_rolls_for_units
    defender_rolls = sorted_dice_rolls(number_of_defenders)
    attacker_rolls = sorted_dice_rolls(@attacking_units)

    defender_rolls.zip(attacker_rolls).reject do |defender, attacker|
      defender.nil? || attacker.nil?
    end
  end

  def sorted_dice_rolls(rolls)
    rolls.times.map { rand(DICE_RANGE) }.sort.reverse
  end

  def attack_result(paired_rolls)
    attackers_lost = paired_rolls.count do |defender_roll, attacker_roll|
      defender_roll >= attacker_roll
    end

    defenders_lost = paired_rolls.length - attackers_lost
    [defenders_lost, attackers_lost]
  end

  def take_over_territory!(defenders_lost, attackers_count)
    create_action!(@territory_to, find_owner(@territory_to), -defenders_lost)
    create_action!(@territory_to, find_owner(@territory_from), attackers_count)
    create_action!(@territory_from, find_owner(@territory_from), -attackers_count)
  end

  def create_action!(territory, territory_owner, units_difference)
    @attack_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
