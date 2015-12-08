class EndTurn
  def initialize(turn)
    @turn = turn
    @game = turn.game
  end

  def call
    #TODO method + modulo
    next_player_index = @game.players.find_index(@turn.player) + 1
    next_player_index = 0 if next_player_index == @game.players.size

    @game.players[next_player_index].events.start_turn.create!

    true
  end
end
