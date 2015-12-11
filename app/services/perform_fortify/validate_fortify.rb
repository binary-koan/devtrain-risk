class PerformFortify
  class ValidateFortify
    attr_reader :errors

    def initialize(territory_to:, territory_from:, turn:, fortifying_units:)
      @territory_to     = territory_to
      @territory_from   = territory_from
      @turn             = turn
      @fortifying_units = fortifying_units
      @errors           = []
    end

    def call
      if same_territory?
        errors << :same_territory
      elsif !valid_link?
        errors << :no_link
      elsif !current_players_territory?
        errors << :wrong_player
      elsif !@turn.can_fortify?(@territory_from, @territory_to)
        errors << :wrong_phase
      elsif fortifying_enemy_territory?
        errors << :fortifying_enemy_territory
      elsif !enough_fortifying_units?
        errors << :not_enough_fortifying_units
      elsif fortifying_too_many_units?
        errors << :fortifying_too_many_units
      end

      errors.none?
    end

    private

    def same_territory?
      @territory_to == @territory_from
    end

    def valid_link?
      @territory_from.connected_territories.include?(@territory_to)
    end

    def current_players_territory?
      find_owner(@territory_from) == @turn.player
    end

    def fortifying_enemy_territory?
      find_owner(@territory_from) != find_owner(@territory_to) && @turn.game_state.units_on_territory(@territory_to) > 0
    end

    def enough_fortifying_units?
      @fortifying_units >= MINIMUM_FORTIFYING_UNITS
    end

    def fortifying_too_many_units?
      @fortifying_units > available_fortifying_units
    end

    def find_owner(territory)
      @turn.game_state.territory_owner(territory)
    end

    def available_fortifying_units
      @turn.game_state.units_on_territory(@territory_from) - MIN_UNITS_ON_TERRITORY
    end
  end
end
