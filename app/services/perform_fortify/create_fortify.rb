class PerformFortify
  class CreateFortify
    def initialize(territory_to:, territory_from:, turn:, fortifying_units:)
      @territory_to     = territory_to
      @territory_from   = territory_from
      @turn             = turn
      @fortifying_units = fortifying_units
      @errors           = []
    end

    def call
      ActiveRecord::Base.transaction do
        @fortify_event = create_fortify_event!
        create_fortify_actions!
      end

      @fortify_event
    end

    private

    def create_fortify_event!
      Event.fortify.create!(
        player: @turn.game_state.territory_owner(@territory_from)
      )
    end

    def create_fortify_actions!
      player = find_owner(@territory_from)
      create_action!(@territory_to, player, @fortifying_units)
      create_action!(@territory_from, player, -@fortifying_units)
    end

    def create_action!(territory, territory_owner, units_difference)
      @fortify_event.actions.create!(
        territory:        territory,
        territory_owner:  territory_owner,
        units_difference: units_difference
      )
    end

    def find_owner(territory)
      @turn.game_state.territory_owner(territory)
    end
  end
end
