class PerformAttack

  MIN_UNITS_ON_TERRITORY = 1
  MAX_ATTACKING_UNITS = 3
  MAX_DEFENDING_UNITS = 2

  attr_reader :errors

  def initialize(territory_from:, territory_to:, game_state:)
    @territory_from = territory_from
    @territory_to   = territory_to
    @game_state     = game_state
    @errors         = []
  end

  def call
    @attack_event = nil # ask about this

    if !valid_link?
      errors << :no_link
    elsif !current_players_territory?
      errors << :wrong_player
    elsif !attacking_different_player?
      errors << :own_territory
    else
      perform_attack
    end

    @attack_event
  end

  private

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
    if number_of_attackers < 1
      errors << :cannot_attack_with_one_unit
    else
      @attack_event = create_attack_event

      defender_rolls, attacker_rolls = units_roll_dice

      create_attack_actions(attacker_rolls, defender_rolls)
    end
  end

  def create_attack_actions(attacker_rolls, defender_rolls)
    defenders_lost, attackers_lost = attack_result(defender_rolls, attacker_rolls)

    if territory_taken?(attackers_lost, attacker_rolls)
      take_over_territory(defenders_lost, attacker_rolls)
    else
      remove_units_from_territory(@territory_to, defenders_lost) if defenders_lost > 0
      remove_units_from_territory(@territory_from, attackers_lost) if attackers_lost > 0
    end
  end

  def territory_taken?(attackers_lost, attacker_rolls)
    remaining_defenders = @game_state.units_on_territory(@territory_to)

    attackers_lost == 0 && remaining_defenders <= attacker_rolls.length
  end

  def units_roll_dice
    defender_rolls = roll_dice(number_of_defenders)
    attacker_rolls = roll_dice(number_of_attackers).first(defender_rolls.length)
    defender_rolls = defender_rolls.first(attacker_rolls.length)
    [defender_rolls, attacker_rolls]
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

  def attack_result(defender_rolls, attacker_rolls)
    attackers_lost = 0
    defender_rolls.each.with_index do |roll, index|
      attackers_lost += 1 if defender_rolls[index] >= attacker_rolls[index]
    end
    defenders_lost = defender_rolls.length - attackers_lost
    [defenders_lost, attackers_lost]
  end

  def take_over_territory(defenders_lost, attacker_rolls)
    remove_units_from_territory(@territory_to, defenders_lost)
    add_units_to_territory(@territory_to, @territory_from, attacker_rolls.length)
    remove_units_from_territory(@territory_from, attacker_rolls.length)
  end

  def remove_units_from_territory(territory, units_lost)
    create_action(
      territory,
      find_owner(territory),
      -units_lost
    )
  end

  def add_units_to_territory(territory_to, territory_from, units_added)
    create_action(
      territory_to,
      find_owner(territory_from),
      units_added
    )
  end

  def create_attack_event
    Event.create!(
      event_type: "attack",
      game: @game_state.game,
      player: @game_state.territory_owner(@territory_from)
    )
  end

  def create_action(territory, territory_owner, units_difference)
    @attack_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
