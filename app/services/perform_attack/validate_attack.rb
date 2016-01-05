class PerformAttack
  class ValidateAttack
    MIN_UNITS_ON_TERRITORY = 1
    MIN_ATTACKING_UNITS    = 1
    MAX_ATTACKING_UNITS    = 3

    attr_reader :errors

    def initialize(game_state:, dice_roller:, territory_from:, territory_to:, attacking_units:)
      @territory_from  = territory_from
      @territory_to    = territory_to
      @attacking_units = attacking_units
      @game_state      = game_state
      @allowed_events  = GetAllowedEvents.new(game_state, game_state.game.events).call
      @errors          = []
    end

    def call
      if !valid_link?
        errors << :no_link
      elsif !player_owns_territory?
        errors << :wrong_player
      elsif !attack_event_allowed?
        errors << :wrong_phase
      elsif !attacking_different_player?
        errors << :own_territory
      elsif too_few_available_attackers?
        errors << :too_few_available_attackers
      elsif too_many_units?
        errors << :too_many_units
      elsif too_few_units?
        errors << :too_few_units
      end

      errors.none?
    end

    private

    def valid_link?
      @territory_from.connected_territories.include?(@territory_to)
    end

    def player_owns_territory?
      find_owner(@territory_from) == @game_state.current_player
    end

    def attack_event_allowed?
      @allowed_events.detect { |event| event.attack? }.present?
    end

    def attacking_different_player?
      find_owner(@territory_from) != find_owner(@territory_to)
    end

    def too_few_available_attackers?
      available_attackers < MIN_ATTACKING_UNITS
    end

    def too_many_units?
      @attacking_units > available_attackers
    end

    def too_few_units?
      @attacking_units < MIN_ATTACKING_UNITS
    end

    def find_owner(territory)
      @game_state.territory_owner(territory)
    end

    def available_attackers
      @game_state.units_on_territory(@territory_from) - MIN_UNITS_ON_TERRITORY
    end
  end
end
