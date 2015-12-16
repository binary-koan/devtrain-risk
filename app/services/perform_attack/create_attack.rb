class PerformAttack
  class CreateAttack
    MAX_DEFENDING_UNITS = 2
    MAX_ATTACKING_UNITS = 3

    attr_reader :dice_rolled

    def initialize(territory_from:, territory_to:, turn:, attacking_units:)
      @territory_from  = territory_from
      @territory_to    = territory_to
      @turn            = turn

      @attacking_units = attacking_units
      @initial_defenders = @turn.game_state.units_on_territory(@territory_to)
      @attackers_lost  = 0
      @defenders_lost  = 0
      @attack_events   = []
      @dice_rolled     = []
      @errors          = []
    end

    def call
      ActiveRecord::Base.transaction do
        while @attacking_units > 0
          dice_rolls = roll_dice(number_of_defenders, number_of_attackers)
          handle_attack!(dice_rolls)

          @dice_rolled << dice_rolls

          @attacking_units -= @attackers_lost
          break if territory_taken?
        end
      end

      @attack_events
    end

    private

    def roll_dice(number_of_defenders, number_of_attackers)
      die_rolls = RollDice.new(number_of_defenders, number_of_attackers)
      die_rolls.call
    end

    def number_of_attackers
      [@attacking_units, MAX_ATTACKING_UNITS].min
    end

    def number_of_defenders
      [@initial_defenders - @defenders_lost, MAX_DEFENDING_UNITS].min
    end

    def handle_attack!(paired_rolls)
      defenders_lost, attackers_lost = attack_result(paired_rolls)

      @attackers_lost = attackers_lost
      @defenders_lost += defenders_lost

      create_attack_event!(@territory_to, @territory_from, defenders_lost) if defenders_lost > 0
      create_attack_event!(@territory_from, @territory_to, attackers_lost) if attackers_lost > 0
    end

    def attack_result(paired_rolls)
      attackers_lost = paired_rolls.count do |defender_roll, attacker_roll|
        defender_roll >= attacker_roll
      end

      defenders_lost = paired_rolls.length - attackers_lost
      [defenders_lost, attackers_lost]
    end

    def territory_taken?
      @defenders_lost == @initial_defenders
    end

    def create_attack_event!(territory, territory_from, units_lost)
      @attack_events << find_owner(territory).events.attack.new
      @attack_events.last.action = Action::Kill.create!(
        territory_from: territory_from,
        territory: territory,
        units: units_lost
      )
      @attack_events.last.save!
    end

    def find_owner(territory)
      @turn.game_state.territory_owner(territory)
    end
  end
end
