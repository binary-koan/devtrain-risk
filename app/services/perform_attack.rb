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

    if !valid_link
      errors << :no_link
    elsif !different_players_territory
      errors << :own_territory
    else
      perform_attack(number_of_attackers, number_of_defenders)
    end
    @attack_event
  end

  private

  def valid_link
    @territory_from.connected_territories.include? @territory_to
  end

  def different_players_territory
    from_owner = @game_state.territory_owner(@territory_from)
    to_owner   = @game_state.territory_owner(@territory_to)

    from_owner != to_owner
  end

  def perform_attack(number_of_attackers, number_of_defenders)
    if number_of_attackers < 1
      errors << :cannot_attack_with_one_unit
    else
      @attack_event = Event.new(
        event_type: :attack,
        game: @game_state.game,
        player: @game_state.territory_owner(@territory_from)
      )
      attacker_rolls = roll_dice(number_of_attackers)
      defender_rolls = roll_dice(number_of_defenders)

      attacker_rolls = attacker_rolls.first(defender_rolls.length)

      successful_defends = 0

      defender_rolls.each.with_index do |roll, index|
        successful_defends += 1 if defender_rolls[index] >= attacker_rolls[index]
      end

      defenders_lost = defender_rolls.length - successful_defends
      attackers_lost = successful_defends # derp

        # killed all units, take territory
      remaining_defenders = @game_state.units_on_territory(@territory_to)

      if successful_defends == 0
        if remaining_defenders <= attacker_rolls.length
          @attack_event.actions.new(
            territory:        @territory_to,
            territory_owner:  @game_state.territory_owner(@territory_to),
            units_difference: -defenders_lost
          )
          @attack_event.actions.new(
            territory:        @territory_to,
            territory_owner:  @game_state.territory_owner(@territory_from),
            units_difference: attacker_rolls.length
          )
         end
      elsif defenders_lost > 0
        @attack_event.actions.new(
          territory:        @territory_to,
          territory_owner:  @game_state.territory_owner(@territory_to),
          units_difference: -defenders_lost
        )
      elsif attackers_lost > 0
        @attack_event.actions.new(
          territory:        @territory_from,
          territory_owner:  @game_state.territory_owner(@territory_from),
          units_difference: -attackers_lost
        )
      end

      unless @attack_event.save
        errors << :failed_save
      end
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
end
