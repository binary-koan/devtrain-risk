class PerformFortify
  MINIMUM_FORTIFYING_UNITS = 1

  attr_reader :errors

  def initialize(territory_to:, territory_from:, game_state:, fortifying_units:)
    @territory_to     = territory_to
    @territory_from   = territory_from
    @game_state       = game_state
    @fortifying_units = fortifying_units
    @errors           = []
  end

  def call
    puts @fortifying_units
    if same_territory?
      errors << :same_territory
    elsif !valid_link?
      errors << :no_link
    elsif !current_players_territory?
      errors << :wrong_player
    elsif !fortifying_own_territory?
      errors << :fortifying_enemy_territory
    elsif !minimum_number_of_units?
      errors << :minimum_number_of_units
    else
      perform_fortify
    end

    @fortify_event
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

  def fortifying_own_territory?
    find_owner(@territory_from) == find_owner(@territory_to)
  end

  def minimum_number_of_units?
    @fortifying_units >= MINIMUM_FORTIFYING_UNITS
  end

  def find_owner(territory)
    @game_state.territory_owner(territory)
  end

  def perform_fortify
    if number_of_units <= 1
      errors << :fortify_with_one_unit
    else
      @fortify_event = create_fortify_event
      create_fortify_actions
    end
  end

  def create_fortify_actions

  end

  def number_of_units
    @game_state.units_on_territory(@territory_from)
  end

  def create_fortify_event
    Event.fortify(
      game: @game_state.game,
      player: @game_state.territory_owner(@territory_from)
    ).tap { |e| e.save!}
  end

  def create_action(territory, territory_owner, units_difference)
    @attack_event.actions.create!(
      territory:        territory,
      territory_owner:  territory_owner,
      units_difference: units_difference
    )
  end
end
