require 'yaml'

module GamesHelper
  PLAYER_COLORS = %w{#4F2EC9 #63242E #40542E #966328 #2E554E #482917}
  MAP_COLORS    = %W{#C0392B #8E44AD #2ECC71 #F1C40F #ECF0F1 #3498DB}
  DEFAULT_TERRITORY_LINK_COLOR = "#666"

  DICE_CHARACTERS  = %w{⚀ ⚁ ⚂ ⚃ ⚄ ⚅}

  MAP_PADDING = 40
  TERRITORY_NODE_SIZE = 30

  def player_color(players, player)
    PLAYER_COLORS[players.find_index(player)]
  end

  def owned_territory_names(game_state)
    #TODO maybe talk to object
    game_state.owned_territories(game_state.current_player).map(&:name).sort
  end

  def enemy_territory_names(game_state)
    (game_state.game.territories.pluck(:name) - owned_territory_names(game_state)).sort
  end

  def continent_color(territories, territory)
    id = territories.detect { |t| territory == t }.continent.color
    MAP_COLORS[id.to_i]
  end

  def map_display(game_state)
    content_tag("svg", class: "map-display", viewbox: map_viewbox(game_state.game.territories)) do
      territory_link_lines(game_state).map { |link| concat link }
      territory_nodes(game_state).map { |node| concat node }
    end
  end

  def hidden_progress_spinner
    content_tag("span", class: "in-progress progress hidden") do
      concat content_tag("span", "", class: "progress-inner")
      concat content_tag("span", "Loading…", class: "sr-only")
    end
  end

  def available_maps
    YAML.load_file(Map::MAP_YAML_LOCATION).keys
  end

  def paired_dice_rolls(paired_roll)
    paired_roll.map { |die| DICE_CHARACTERS[die - 1] }.join
  end

  private

  def map_viewbox(territories)
    x_min, x_max = territories.map(&:x).minmax
    y_min, y_max = territories.map(&:y).minmax
    offset = TERRITORY_NODE_SIZE + MAP_PADDING

    "#{x_min - offset} #{y_min - offset} #{x_max + offset * 2} #{y_max + offset * 2}"
  end

  def territory_link_lines(game_state)
    game_state.territory_links.map do |link|
      content_tag("line", "",
        class: "link",
        stroke: link_color(link),
        x1: link[0].x,
        y1: link[0].y,
        x2: link[1].x,
        y2: link[1].y
      )
    end
  end

  def link_color(link)
    if link[0].continent == link[1].continent
      MAP_COLORS[link[0].continent.color.to_i]
    else
      DEFAULT_TERRITORY_LINK_COLOR
    end
  end

  def territory_nodes(game_state)
    game_state.game.territories.map do |territory|
      content_tag("g", transform: translate(territory.x, territory.y)) do
        territory_node_content(territory, game_state)
      end
    end
  end

  def territory_node_content(territory, game_state)
    color = player_color(game_state.game.players, game_state.territory_owner(territory))
    stroke_color = continent_color(game_state.game.territories, territory)
    units = game_state.units_on_territory(territory)

    content_tag("g", class: "node") do
      concat territory_image
      concat territory_circle(color, stroke_color)
      concat territory_name_text(territory.name)
      concat territory_units_text(units)
    end
  end

  def territory_image
    content_tag("image", "",
      "xlink:href" => image_path("planet.png"),
      "x"          => -TERRITORY_NODE_SIZE,
      "y"          => -TERRITORY_NODE_SIZE,
      "width"      => TERRITORY_NODE_SIZE * 2,
      "height"     => TERRITORY_NODE_SIZE * 2
    )
  end

  def territory_circle(color, stroke_color)
    content_tag("circle", "", r: TERRITORY_NODE_SIZE, fill: color, stroke: stroke_color)
  end

  def territory_name_text(name)
    content_tag("text", name, "text-anchor" => "middle", "dy" => -3)
  end

  def territory_units_text(units)
    content_tag("text", "#{units} units", "class" => "units-display", "text-anchor" => "middle", "dy" => 12)
  end

  def translate(x, y = x)
    "translate(#{x},#{y})"
  end
end
