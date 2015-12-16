class StartNextTurn
  attr_reader :errors

  def initialize(turn)
    @turn = turn
    @game = turn.game
    @errors = []
  end

  def call
    if @turn.can_start_next_turn?
      start_next_turn!
    else
      @errors << :wrong_phase
    end

    @errors.none?
  end

  private

  def start_next_turn!
    next_player = @game.players[next_player_index]

    until @turn.game_state.in_game?(next_player)
      next_player = @game.players[next_player_index]
    end

    next_player.events.start_turn.create!
  end

  def next_player_index
    @next_player_index ||= current_player_index
    @next_player_index += 1

    @next_player_index % @game.players.size
  end

  def current_player_index
    @game.players.find_index(@turn.player)
  end
end
