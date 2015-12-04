class BuildGameState
  def initialize(game, events)
    @game = game
    @events = events
    @turns = []
  end

  def call
    build_turns

    GameState.new(@game, @turns)
  end

  private

  def build_turns
    current_player = nil
    current_events = []
    @events.each do |event|
      if event.start_turn?
        @turns << Turn.new(current_player, current_events)
        current_player = event.player
        current_events = []
      else
        current_events << event
      end
    end
    @turns << Turn.new(current_player, current_events)
  end
end
