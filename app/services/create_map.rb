require 'yaml'

class CreateMap
  MAP_YAML_LOCATION    = "config/maps.yml"
  TERRITORY_COUNT      = "territory_count"
  TERRITORY_POSITIONS  = "territory_positions"
  TERRITORY_EDGES      = "territory_edges"
  TERRITORY_CONTINENTS = "territory_continents"

  attr_reader :errors

  def initialize(game:, map_name:)
    @game             = game
    @name             = map_name
    @available_colors = %w{#c0392b #8e44ad #2ecc71 #f1c40f #ecf0f1 #3498db}
    @territories      = []
    @errors           = []
  end

  def call
    load_yaml

    if !valid_map?
      errors << :not_valid_map_name
    else
      load_map

      ActiveRecord::Base.transaction do
        create_territories!
        create_continents
        create_territory_links!
      end
    end

    errors.empty?
  end

  def valid_map?
    @yaml.key?(@name)
  end

  private

  def load_yaml
    @yaml   = YAML.load_file(MAP_YAML_LOCATION)
  end

  def load_map
    map_info = @yaml[@name]

    @territory_count = map_info[TERRITORY_COUNT]
    @territory_positions = map_info[TERRITORY_POSITIONS]
    @territory_edges = map_info[TERRITORY_EDGES]
    @territory_continents = map_info[TERRITORY_CONTINENTS]
  end

  def create_territory_links!
    @territory_edges.each do |edge|
      TerritoryLink.create!(
        from_territory: @game.territories[edge[0]],
        to_territory: @game.territories[edge[1]]
      )
    end
  end

  def create_territories!
    @territory_count.times do |i|
      @territories << Territory.new(
        x: @territory_positions[i][0],
        y: @territory_positions[i][1],
        name: GenerateName.new.call
      )
    end
  end

  def create_continents
    @territory_continents.each do |territory_positions|
      continent = @game.continents.create!(
        color: pick_continent_color
      )

      link_territories(continent, territory_positions)
    end

    @territories.each do |t|
      t.save!
    end
  end

  def link_territories(continent, territory_positions)
    territory_positions.each do |t|
      territory = @territories[t]
      territory.continent = continent
      @territories[t] = territory
    end
  end

  def pick_continent_color
    @available_colors.pop
  end
end
