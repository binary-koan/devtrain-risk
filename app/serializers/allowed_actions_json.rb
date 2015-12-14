class AllowedActionsJson
  def initialize(turn)
    @turn = turn
  end

  def json
    @turn.allowed_events.map { |event| json_for_event(event) }
  end

  private

  def json_for_event(event)
    {
      eventType: event.event_type
    }
  end
end
