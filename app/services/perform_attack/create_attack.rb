class PerformAttack
  class CreateAttack
    MAX_DEFENDING_UNITS = 2
    MAX_ATTACKING_UNITS = 3

    def initialize(territory_from:, territory_to:, turn:, attacking_units:)
      @territory_from  = territory_from
      @territory_to    = territory_to
      @turn            = turn
      @attacking_units = attacking_units
      @attackers_lost  = 0
      @defenders_lost  = 0
      @errors          = []
    end

    def call
      defenders = @turn.game_state.units_on_territory(@territory_to)
      ActiveRecord::Base.transaction do
        while @attacking_units > 0
          create_attack_event!
          attackers = number_of_attackers
          dice_rolls = roll_dice(number_of_attackers)
          create_attack_actions!(dice_rolls)

          @attacking_units -= @attackers_lost
          if @defenders_lost >= defenders
            break
          end
        end
      end

      @attack_event
    end

    private

    def create_attack_event!
      @attack_event = find_owner(@territory_from).events.attack.create!
    end

    def roll_dice(number_of_attackers)
      die_rolls = RollDice.new(number_of_defenders, number_of_attackers)
      die_rolls.call
    end

    def number_of_attackers
      [@attacking_units, MAX_ATTACKING_UNITS].min
    end

    def number_of_defenders
      units = @turn.game_state.units_on_territory(@territory_to)
      [units, MAX_DEFENDING_UNITS].min
    end

    def create_attack_actions!(paired_rolls)
      defenders_lost, attackers_lost = attack_result(paired_rolls)

      @attackers_lost = attackers_lost
      @defenders_lost += defenders_lost

      if territory_taken?(defenders_lost)
        take_over_territory!(defenders_lost, paired_rolls.length)
      else
        create_action!(:kill, @territory_to, find_owner(@territory_to), -defenders_lost) if defenders_lost > 0
        create_action!(:kill, @territory_from, find_owner(@territory_from), -attackers_lost) if attackers_lost > 0
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
      create_action!(:kill, @territory_to, find_owner(@territory_to), -defenders_lost)
      create_action!(:move_to, @territory_to, find_owner(@territory_from), attackers_count)
      create_action!(:move_from, @territory_from, find_owner(@territory_from), -attackers_count)
    end

    def create_action!(type, territory, territory_owner, units_difference)
      @attack_event.actions.create!(
        action_type:      type,
        territory:        territory,
        territory_owner:  territory_owner,
        units_difference: units_difference
      )
    end
  end
end
