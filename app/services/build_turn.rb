class BuildTurn
  def initialize(events)
    @events = events
  end

  def call
    turn_groups.inject(nil) do |previous_turn, events|
      Turn.new(events, previous_turn)
    end
  end

  private

  def turn_groups
    #TODO look for Enumerable thing
    @events.inject([[]]) do |groups, event|
      if event.start_turn?
        groups << [event]
      else
        groups.tap { |g| g.last << event }
      end
    end
  end
end
