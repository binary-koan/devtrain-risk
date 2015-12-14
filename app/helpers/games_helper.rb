require 'yaml'

module GamesHelper
  PLAYER_COLORS    = %w{#4F2EC9 #63242E}

  DEFAULT_TERRITORY_LINK_COLOR = "#666"

  MAP_YAML_LOCATION = "config/maps.yml"

  MAP_PADDING = 40
  TERRITORY_NODE_SIZE = 30

  def player_color(players, player)
    PLAYER_COLORS[players.find_index(player)]
  end

  def continent_color(territories, territory)
    territories.detect { |t| territory == t }.continent.color
  end

  def map_display(turn)
    content_tag(
      "svg",
      map_display_content(turn),
      class: "map-display",
      viewbox: map_viewbox(turn.game.territories)
    )
  end

  def available_maps
    YAML.load_file(MAP_YAML_LOCATION).keys
  end

  private

  def map_viewbox(territories)
    x_min, x_max = territories.map(&:x).minmax
    y_min, y_max = territories.map(&:y).minmax
    offset = TERRITORY_NODE_SIZE + MAP_PADDING

    "#{x_min - offset} #{y_min - offset} #{x_max + offset * 2} #{y_max + offset * 2}"
  end

  def map_display_content(turn)
    (territory_link_lines(turn) + territory_nodes(turn)).join.html_safe
  end

  def territory_link_lines(turn)
    turn.game_state.territory_links.map do |link|
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
      link[0].continent.color
    else
      DEFAULT_TERRITORY_LINK_COLOR
    end
  end

  def territory_nodes(turn)
    turn.game.territories.map do |territory|
      children = territory_node_content(territory, turn)

      content_tag("g", children, class: "node", transform: translate(territory.x, territory.y))
    end
  end

  def territory_node_content(territory, turn)
    color = player_color(turn.game.players, turn.game_state.territory_owner(territory))
    stroke_color = continent_color(turn.game.territories, territory)
    units = turn.game_state.units_on_territory(territory)

    image = content_tag("image", "",
      "xlink:href" => image_path("planet.png"),
      "x"          => -TERRITORY_NODE_SIZE,
      "y"          => -TERRITORY_NODE_SIZE,
      "width"      => TERRITORY_NODE_SIZE * 2,
      "height"     => TERRITORY_NODE_SIZE * 2
    )

    [
      image,
      content_tag("circle", "", r: TERRITORY_NODE_SIZE, fill: color, stroke: stroke_color),
      content_tag("text", territory.name, "text-anchor" => "middle", "dy" => -3),
      content_tag("text", "#{units} units", "class" => "units-display", "text-anchor" => "middle", "dy" => 12)
    ].join.html_safe
  end

  def translate(x, y = x)
    "translate(#{x},#{y})"
  end
end
