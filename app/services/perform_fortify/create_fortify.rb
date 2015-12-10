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
        @fortify_event = create_fortify_event!(create_fortify_action!)
      end

      @fortify_event
    end

    private

    def create_fortify_event!(action)
      find_owner(@territory_from).events.fortify.create!(action: action)
    end

    def create_fortify_action!
      Action::Move.create!(territory_from: @territory_from, territory_to: @territory_to, units: @fortifying_units)
    end

    def find_owner(territory)
      @turn.game_state.territory_owner(territory)
    end
  end
end
