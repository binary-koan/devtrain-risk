class EndTurn
  def initialize(turn)
    @turn = turn
    @game = turn.game
  end

  def call
    next_player_index = @game.players.find_index(@turn.player) + 1
    next_player_index = 0 if next_player_index == @game.players.size

    @game.events.start_turn(player: @game.players[next_player_index]).save!

    true
  end
end
