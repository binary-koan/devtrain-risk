class PerformAttack
  class RollDice
    DICE_RANGE = 1..6

    def initialize(defending_units, attacking_units)
      @defending_units = defending_units
      @attacking_units = attacking_units
    end

    def call
      defender_rolls = sorted_dice_rolls(@defending_units)
      attacker_rolls = sorted_dice_rolls(@attacking_units)

      defender_rolls.zip(attacker_rolls).reject do |defender, attacker|
        defender.nil? || attacker.nil?
      end
    end

    private

    def sorted_dice_rolls(rolls)
      rolls.times.map { rand(DICE_RANGE) }.sort.reverse
    end
  end
end
