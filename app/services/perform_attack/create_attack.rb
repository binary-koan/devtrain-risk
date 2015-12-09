class PerformAttack
  class CreateAttack
    MAX_DEFENDING_UNITS = 2

    def initialize(territory_from:, territory_to:, turn:, attacking_units:)
      @territory_from  = territory_from
      @territory_to    = territory_to
      @turn            = turn
      @attacking_units = attacking_units
      @errors          = []
    end

    def call
      ActiveRecord::Base.transaction do
        create_attack_event!
        create_attack_actions!(roll_dice)
      end

      @attack_event
    end

    private

    def create_attack_event!
      @attack_event = find_owner(@territory_from).events.attack.create!
    end

    def roll_dice
      die_rolls = RollDice.new(number_of_defenders, @attacking_units)
      die_rolls.call
    end

    def number_of_defenders
      units = @turn.game_state.units_on_territory(@territory_to)
      [units, MAX_DEFENDING_UNITS].min
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

    def attack_result(paired_rolls)
      attackers_lost = paired_rolls.count do |defender_roll, attacker_roll|
        defender_roll >= attacker_roll
      end

      defenders_lost = paired_rolls.length - attackers_lost
      [defenders_lost, attackers_lost]
    end

    def territory_taken?(defenders_lost)
      remaining_defenders = @turn.game_state.units_on_territory(@territory_to)

      defenders_lost == remaining_defenders
    end

    def find_owner(territory)
      @turn.game_state.territory_owner(territory)
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
end
