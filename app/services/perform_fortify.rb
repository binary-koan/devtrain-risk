class PerformFortify
  MIN_UNITS_ON_TERRITORY   = 1
  MINIMUM_FORTIFYING_UNITS = 1

  attr_reader :errors, :fortify_event

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
    elsif !@turn.can_fortify?
      errors << :wrong_phase
    elsif !fortifying_own_territory?
      errors << :fortifying_enemy_territory
    elsif !enough_fortifying_units?
      errors << :not_enough_fortifying_units
    else
      perform_fortify
    end

    @fortify_event.present?
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

  def fortifying_own_territory?
    find_owner(@territory_from) == find_owner(@territory_to)
  end

  def enough_fortifying_units?
    @fortifying_units >= MINIMUM_FORTIFYING_UNITS
  end

  def find_owner(territory)
    @turn.game_state.territory_owner(territory)
  end

  def perform_fortify
    if @fortifying_units > available_fortifying_units
      errors << :fortifying_too_many_units
    else
      ActiveRecord::Base.transaction do
        @fortify_event = create_fortify_event!
        create_fortify_actions!
      end
    end
  end

  def available_fortifying_units
    @turn.game_state.units_on_territory(@territory_from) - MIN_UNITS_ON_TERRITORY
  end

  def create_fortify_event!
    Event.fortify(
      game: @turn.game,
      player: @turn.game_state.territory_owner(@territory_from)
    ).tap { |e| e.save! }
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
end
