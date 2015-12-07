class PerformAttack
  MIN_UNITS_ON_TERRITORY  = 1
  MIN_ATTACKING_UNITS     = 1
  MAX_ATTACKING_UNITS     = 3
  MAX_DEFENDING_UNITS     = 2

  attr_reader :errors, :attack_event

  def initialize(territory_from:, territory_to:, game_state:, attacking_units: nil)
    @territory_from  = territory_from
    @territory_to    = territory_to
    @game_state      = game_state
    @attacking_units = attacking_units || default_attacking_units
    @errors          = []
  end

  def call
    if !valid_link?
      errors << :no_link
    elsif !current_players_territory?
      errors << :wrong_player
    elsif !@game_state.can_attack?
      errors << :wrong_phase
    elsif !attacking_different_player?
      errors << :own_territory
    else
      perform_attack
    end

    @attack_event.present?
  end

  private

  def default_attacking_units
    number_of_attackers
  end

  def too_many_units?
     @attacking_units > 3 || @attacking_units > number_of_attackers
  end

  def valid_link?
    @territory_from.connected_territories.include?(@territory_to)
  end

  def current_players_territory?
    find_owner(@territory_from) == @game_state.current_player
  end

  def attacking_different_player?
    find_owner(@territory_from) != find_owner(@territory_to)
  end

  def find_owner(territory)
    @game_state.territory_owner(territory)
  end

  def perform_attack
    if number_of_attackers < MIN_ATTACKING_UNITS
      errors << :cannot_attack_with_one_unit
      @attack_event = nil
    elsif too_many_units?
        errors << :too_many_units
    else
      ActiveRecord::Base.transaction do
        @attack_event = create_attack_event

        paired_rolls = units_roll_dice

        create_attack_actions(paired_rolls)
      end
    end
  end

  def create_attack_event
    Event.attack(
      game: @game_state.game,
      player: @game_state.territory_owner(@territory_from)
    ).tap { |e| e.save!}
  end

  def units_roll_dice
    defender_rolls = roll_dice(number_of_defenders)
    attacker_rolls = roll_dice(@attacking_units)

    defender_rolls.zip(attacker_rolls).reject do |(defender, attacker)|
      defender.nil? || attacker.nil?
    end
  end

  def create_attack_actions(paired_rolls)
    defenders_lost, attackers_lost = attack_result(paired_rolls)

    if territory_taken?(defenders_lost)
      take_over_territory(defenders_lost, paired_rolls.length)
    else
      create_action(@territory_to, find_owner(@territory_to), -defenders_lost) if defenders_lost > 0
      create_action(@territory_from, find_owner(@territory_from), -attackers_lost) if attackers_lost > 0
    end
  end

  def territory_taken?(defenders_lost)
    remaining_defenders = @game_state.units_on_territory(@territory_to)

    defenders_lost == remaining_defenders
  end

  def number_of_attackers
    units = @game_state.units_on_territory(@territory_from) - MIN_UNITS_ON_TERRITORY
    if units > MAX_ATTACKING_UNITS
      MAX_ATTACKING_UNITS
    else
      units
    end
  end

  def number_of_defenders
    units = @game_state.units_on_territory(@territory_to)
    if units > MAX_DEFENDING_UNITS
      MAX_DEFENDING_UNITS
    else
      units
    end
  end

  def roll_dice(rolls)
    rolls.times.map { rand(1..6) }.sort.reverse
  end

  def attack_result(paired_rolls)
    attackers_lost = paired_rolls.select do |(defender_roll, attacker_roll)|
      defender_roll >= attacker_roll
    end.length

    defenders_lost = paired_rolls.length - attackers_lost
    [defenders_lost, attackers_lost]
  end

  def take_over_territory(defenders_lost, attackers_count)
    create_action(@territory_to, find_owner(@territory_to), -defenders_lost)
    create_action(@territory_to, find_owner(@territory_from), attackers_count)
    create_action(@territory_from, find_owner(@territory_from), -attackers_count)
  end

  def create_action(territory, territory_owner, units_difference)
    @attack_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
