class EndTurn
  def initialize(turn)
    @turn = turn
    @game = turn.game
  end

  def call
    current_player = @turn.player
    next_player_index = @game.players.find_index(current_player) + 1
    next_player_index = 0 if next_player_index == @game.players.size

    @game.events.start_turn(player: @game.players[next_player_index]).save!
  end
end
