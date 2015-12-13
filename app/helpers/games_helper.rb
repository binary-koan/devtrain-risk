require 'yaml'

module GamesHelper
  PLAYER_COLORS = %w{#4F2EC9 #63242E}

  MAP_YAML_LOCATION = "config/maps.yml"

  def player_color(players, player)
    PLAYER_COLORS[players.find_index(player)]
  end

  def available_maps
    YAML.load_file(MAP_YAML_LOCATION).keys
  end
end
