class EndTurn
  def initialize(game_state)
    @game_state = game_state
  end

  def call
    current_player = @game_state.current_player
    next_player_index = @game_state.game.players.find_index(current_player) + 1
    next_player_index = 0 if next_player_index == @game_state.game.players.size

    @game_state.game.events.start_turn(player: @game_state.game.players[next_player_index]).save!
  end
end
