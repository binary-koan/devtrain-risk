class Map
  MAP_YAML_LOCATION    = "config/maps.yml"
  TERRITORY_COUNT      = "territory_count"
  TERRITORY_POSITIONS  = "territory_positions"
  TERRITORY_EDGES      = "territory_edges"
  TERRITORY_CONTINENTS = "territory_continents"

  attr_reader :errors, :territory_count, :territory_positions,
              :territory_edges, :territory_continents

  def initialize(map_name:)
    @map_name = map_name
    @errors   = []
  end

  def load
    load_yaml

    if valid_map?
      load_map
    else
      @errors << :not_valid_map_name
    end
  end

  private

  def valid_map?
    @yaml.key?(@map_name)
  end

  def load_yaml
    @yaml = YAML.load_file(MAP_YAML_LOCATION)
  end

  def load_map
    map_info = @yaml[@map_name]

    @territory_count = map_info[TERRITORY_COUNT]
    @territory_positions = map_info[TERRITORY_POSITIONS]
    @territory_edges = map_info[TERRITORY_EDGES]
    @territory_continents = map_info[TERRITORY_CONTINENTS]
  end
end
