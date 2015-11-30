class PerformAttack
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
      perform_attack(number_of_attackers, number_of_defenders)
    end
    @attack_event
  end

  private

  def valid_link?
    @territory_from.connected_territories.include?(@territory_to)
  end

  def current_players_territory?
    @game_state.territory_owner(@territory_from) == @game_state.current_player
  end

  def attacking_different_player?
    from_owner = @game_state.territory_owner(@territory_from)
    to_owner   = @game_state.territory_owner(@territory_to)

    from_owner != to_owner
  end

  def perform_attack(number_of_attackers, number_of_defenders)
    if number_of_attackers < 1
      errors << :cannot_attack_with_one_unit
    else
      @attack_event = create_attack_event

      defender_rolls = roll_dice(number_of_defenders)
      attacker_rolls = roll_dice(number_of_attackers).first(defender_rolls.length)
      defender_rolls = defender_rolls.first(attacker_rolls.length)

      successful_defends = 0

      defender_rolls.each.with_index do |roll, index|
        successful_defends += 1 if defender_rolls[index] >= attacker_rolls[index]
      end

      create_attack_actions(attacker_rolls, defender_rolls, successful_defends)
    end
  end

  def create_attack_actions(attacker_rolls, defender_rolls, successful_defends)
    defenders_lost = defender_rolls.length - successful_defends
    attackers_lost = successful_defends # derp

    # killed all units, take territory
    remaining_defenders = @game_state.units_on_territory(@territory_to)

    if successful_defends == 0 && remaining_defenders <= attacker_rolls.length
      take_over_territory(defenders_lost, attacker_rolls)
    else
      remove_defenders(defenders_lost) if defenders_lost > 0
      remove_attackers(attackers_lost) if attackers_lost > 0
    end
  end

  def number_of_attackers
    units = @game_state.units_on_territory(@territory_from) - 1
    if units > 3
      3
    else
      units
    end
  end

  def number_of_defenders
    units = @game_state.units_on_territory(@territory_to)
    if units > 2
      2
    else
      units
    end
  end

  def roll_dice(rolls)
    rolls.times.map { rand(1..6) }.sort.reverse
  end

  def take_over_territory(defenders_lost, attacker_rolls)
    remove_defenders(defenders_lost)

    #TODO this final action should be a reinforce not an attack

    create_action(
      @territory_to,
      @game_state.territory_owner(@territory_from),
      attacker_rolls.length
    )

    create_action(
      @territory_from,
      @game_state.territory_owner(@territory_from),
      -attacker_rolls.length
    )
  end

  def remove_attackers(attackers_lost)
    create_action(
      @territory_from,
      @game_state.territory_owner(@territory_from),
      -attackers_lost
    )
  end

  def remove_defenders(defenders_lost)
    create_action(
      @territory_to,
      @game_state.territory_owner(@territory_to),
      -defenders_lost
    )
  end

  def create_attack_event
    @attack_event = Event.create!(
      event_type: :attack,
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
