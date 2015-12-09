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
        create_fortify_event!
        create_fortify_actions!
      end

      @fortify_event
    end

    private

    def create_fortify_event!
      @fortify_event = find_owner(@territory_from).events.fortify.create!
    end

    def create_fortify_actions!
      player = find_owner(@territory_from)
      create_action!(:move_to, @territory_to, player, @fortifying_units)
      create_action!(:move_from, @territory_from, player, -@fortifying_units)
    end

    def create_action!(type, territory, territory_owner, units_difference)
      @fortify_event.actions.create!(
        action_type:      type,
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
