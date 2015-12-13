require 'yaml'

module GamesHelper
  MAP_YAML_LOCATION = "config/maps.yml"

  def available_maps
    YAML.load_file(MAP_YAML_LOCATION).keys
  end
end
