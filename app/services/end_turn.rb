class EndTurn
  def initialize(game)
    @game = game
    @game_state = GameState.new(game)
  end

  def call
    current_player = @game_state.current_player
    next_player_index = @game.players.find_index(current_player) + 1
    next_player_index = 0 if next_player_index == @game.players.size

    @game.events.create!(player: @game.players[next_player_index], event_type: "start_turn")

    reinforcement_units = PerformReinforce.new(
                            game_state: @game_state,
                            current_player: @game_state.current_player
                          )
    reinforcement_units.call
  end
end
