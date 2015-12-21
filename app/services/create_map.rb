require 'yaml'

class CreateMap
  attr_reader :errors

  def initialize(game:, map_name:)
    @game             = game
    @name             = map_name
    #TODO in helper, not database
    @available_colors = %w{#c0392b #8e44ad #2ecc71 #f1c40f #ecf0f1 #3498db}
    @territories      = []
    @errors           = []
  end

  def call
    load_map

    if @map.errors.any?
      @errors = @map.errors
    else
      ActiveRecord::Base.transaction do
        create_territories!
        create_continents
        create_territory_links!
      end
    end

    @errors.empty?
  end

  private

  def load_map
    @map = Map.new(map_name: @name)
    @map.load
  end

  def create_territory_links!
    @map.territory_edges.each do |edge|
      TerritoryLink.create!(
        from_territory: @game.territories[edge[0]],
        to_territory: @game.territories[edge[1]]
      )
    end
  end

  def create_territories!
    names = generate_names

    @map.territory_count.times do |i|
      @territories << Territory.new(
        x: @map.territory_positions[i][0],
        y: @map.territory_positions[i][1],
        name: names[i]
      )
    end
  end

  def create_continents
    @map.territory_continents.each do |territory_positions|
      continent = @game.continents.create!(
        color: pick_continent_color
      )

      link_territories(continent, territory_positions)
    end

    @territories.each(&:save!)
  end

  def link_territories(continent, territory_positions)
    territory_positions.each do |t|
      territory = @territories[t]
      territory.continent = continent
      @territories[t] = territory
    end
  end

  def generate_names
    @map.territory_count.times.inject([]) do |names|
      service = GenerateName.new
      name = service.call
      name = service.call while names.include?(name)

      names << name
    end
  end

  def pick_continent_color
    @available_colors.pop
  end
end
