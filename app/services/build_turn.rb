class BuildTurn
  def initialize(events)
    @events = events
    @turns = []
  end

  def call
    all_turns.last
  end

  private

  def all_turns
    current_turn = nil
    turn_groups.map do |events|
      current_turn = Turn.new(events, current_turn)
    end
  end

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
