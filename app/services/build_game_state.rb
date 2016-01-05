class BuildGameState
  def initialize(events)
    @events = events
  end

  def call
    @game_state = GameState.new(@events.first.game)

    @events.each { |event| apply_event(event) }

    @game_state
  end

  private

  def apply_event(event)
    if event.start_turn?
      @game_state.current_player = event.player
    end

    case event.action
    when Action::Kill
      @game_state.update_territory(event.action.territory, event.player, -event.action.units)
    when Action::Add
      @game_state.update_territory(event.action.territory, event.player, event.action.units)
    when Action::Move
      @game_state.update_territory(event.action.territory_from, event.player, -event.action.units)
      @game_state.update_territory(event.action.territory_to, event.player, event.action.units)
    end
  end

  def fortifying_after_attack?(event, previous_event)
    previous_event = event_before(event)
    return unless previous_event.attack?

    attack = previous_event.action

    attack.territory_from == event.action.territory_from && attack.territory == event.action.territory_to
  end

  def event_before(event)
    @events[@events.find_index(event) - 1]
  end
end
