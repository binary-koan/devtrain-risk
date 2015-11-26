class PerformAttack
  include ActiveModel::Errors

  def initialize(territory_from, territory_to, game_state)
    @territory_from = territory_from
    @territory_to = territory_to
    @game_state = game_state
  end

  def call
    if !valid_link
      errors.add "No link between these territories."
    elsif !different_players_territory
      errors.add "Cannt attack your own territory."
    else
      perform_attack(number_of_attackers, number_of_defenders)
    #update_territories
    end
  end

  private

  def valid_link
    !TerritoryLink.where(from_territory: @territory_from, to_territory: @territory_to).none?
  end

  def different_players_territory
    from_owner = Action.where(territory: @from_territory).last.territory_owner
    to_owner = Action.where(territory: @territory_to).last.territory_owner
    from_owner != to_owner
  end

  def perform_attack(number_of_attackers, number_of_defenders)
    if number_of_attackers < 1
      errors.add "Cannot attack with only one unit."
    else
      attacker_rolls = number_of_attackers.roll_dice
      defender_rolls = number_of_defenders.roll_dice

      attacker_rolls = attacker_rolls.first(defender_rolls.length)

      successful_defends = defender_rolls.inject(0).with_index do |total, index, roll|
        total + 1 if defender_rolls[index] >= attacker_rolls[index]
      end

      defenders_lost = defender_rolls - successful_defends

      # killed all units, take territory
      if successful_defends == 0

      elsif defenders_lost > 0
        # remove defenders
      elsif successful_defends
        # remove some attackers
      end
    end
  end

  def number_of_attackers
    @game_state.find_number_of_units(territory_from) - 1
  end

  def number_of_defenders
    @game_state.find_number_of_units(territory_to)
  end

  def roll_dice
    times.map { rand(1..6) }.sort
  end
end
