class EndTurn
  def initialize(turn)
    @turn = turn
    @game = turn.game
  end

  def call
    next_player = @game.players[next_player_index]
    next_player.events.start_turn.create!

    true
  end

  private

  def next_player_index
    (current_player_index + 1) % @game.players.size
  end

  def current_player_index
    @game.players.find_index(@turn.player)
  end
end
