class BuildTurn
  def initialize(events)
    @events = events
  end

  def call
    start_turn_indexes = @events.each.with_index
      .select { |event, i| event.start_turn? }
      .map { |event, i| i }
    start_turn_indexes = [0, *start_turn_indexes, @events.length]

    turn_groups = start_turn_indexes.each_cons(2)
      .map { |start, finish| @events[start...finish] }

    current_turn = nil
    turn_groups.each do |events|
      next if events.empty? #TODO why is something empty?
      current_turn = Turn.new(events, current_turn)
    end

    current_turn
  end
end
