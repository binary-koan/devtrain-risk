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

  #TODO events.chunk(start_turn)

  def turn_groups
    [0, *start_turn_indexes, @events.length].each_cons(2).map do |start_index, next_index|
      @events[start_index..next_index]
    end
  end

  def start_turn_indexes
    @events.each.with_index
      .select { |event, i| event.start_turn? }
      .map { |event, i| i }
  end
end
