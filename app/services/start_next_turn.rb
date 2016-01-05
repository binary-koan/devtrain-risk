class StartNextTurn
  attr_reader :errors

  def initialize(game_state)
    @game_state = game_state
    @allowed_events = GetAllowedEvents.new(game_state, game_state.game.events).call
    @errors = []
  end

  def call
    if @allowed_events.detect(&:start_turn?).present?
      start_next_turn!
    else
      @errors << :wrong_phase
    end

    @errors.none?
  end

  private

  def start_next_turn!
    next_player = @game_state.game.players[next_player_index]

    until @game_state.in_game?(next_player)
      next_player = @game_state.game.players[next_player_index]
    end

    next_player.events.start_turn.create!
  end

  def next_player_index
    @next_player_index ||= current_player_index
    @next_player_index += 1

    @next_player_index % @game_state.game.players.size
  end

  def current_player_index
    @game_state.game.players.find_index(@game_state.current_player)
  end
end
