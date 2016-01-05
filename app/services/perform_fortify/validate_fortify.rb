class PerformFortify
  class ValidateFortify
    attr_reader :errors

    def initialize(game_state:, territory_to:, territory_from:, fortifying_units:)
      @territory_to     = territory_to
      @territory_from   = territory_from
      @fortifying_units = fortifying_units
      @game_state       = game_state
      @allowed_events   = GetAllowedEvents.new(game_state, game_state.game.events).call
      @errors           = []
    end

    def call
      if same_territory?
        errors << :same_territory
      elsif !valid_link?
        errors << :no_link
      elsif !current_players_territory?
        errors << :wrong_player
      elsif !can_fortify?
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
      find_owner(@territory_from) == @game_state.current_player
    end

    def can_fortify?
      fortify_event = @allowed_events.detect(&:fortify?)

      if fortify_event.blank?
        false
      elsif fortify_event.action
        fortify_event.action.territory_from == @territory_from &&
          fortify_event.action.territory_to == @territory_to
      else
        true
      end
    end

    def fortifying_enemy_territory?
      correct_territory_owner && units_on_territory
    end

    def correct_territory_owner
      find_owner(@territory_from) != find_owner(@territory_to)
    end

    def units_on_territory
      @game_state.units_on_territory(@territory_to) > 0
    end

    def enough_fortifying_units?
      @fortifying_units >= MINIMUM_FORTIFYING_UNITS
    end

    def fortifying_too_many_units?
      @fortifying_units > available_fortifying_units
    end

    def find_owner(territory)
      @game_state.territory_owner(territory)
    end

    def available_fortifying_units
      @game_state.units_on_territory(@territory_from) - MIN_UNITS_ON_TERRITORY
    end
  end
end
