require 'yaml'

class CreateMap
  MAP_YAML_LOCATION   = "config/maps.yml"
  TERRITORY_COUNT     = "territory_count"
  TERRITORY_POSITIONS = "territory_positions"
  TERRITORY_EDGES     = "territory_edges"

  attr_reader :map, :errors

  def initialize(game:, map_name:)
    @game   = game
    @name   = map_name
    @errors = []
  end

  def call
    load_yaml

    if !valid_map?
      errors << :not_valid_map_name
    else
      load_map

      ActiveRecord::Base.transaction do
        create_territories!
        create_territory_links!
      end
    end

    @game.territories
  end

  private

  def load_yaml
    @yaml   = YAML.load_file(MAP_YAML_LOCATION)
  end

  def valid_map?
    @yaml.key?(@name)
  end

  def load_map
    map_info = @yaml[@name]

    @territory_count = map_info[TERRITORY_COUNT]
    @territory_positions = map_info[TERRITORY_POSITIONS]
    @territory_edges = map_info[TERRITORY_EDGES]
  end

  def create_territories!
    @territory_count.times do |i|
      @game.territories.create!(
        x: @territory_positions[i][0],
        y: @territory_positions[i][1],
        name: GenerateName.new.call
      )
    end
  end

  def create_territory_links!
    @territory_edges.each do |edge|
      TerritoryLink.create!(
        from_territory: @game.territories[edge[0]],
        to_territory: @game.territories[edge[1]]
      )
    end
  end
end
