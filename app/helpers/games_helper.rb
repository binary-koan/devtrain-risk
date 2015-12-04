module GamesHelper
  PLAYER_COLORS = %w{#4F2EC9 #63242E}

  def player_color(game, player)
    PLAYER_COLORS[game.players.find_index(player)]
  end
end
