module GamesHelper
  PLAYER_COLORS = %w{#4F2EC9 #63242E}

  MAP_WIDTH = 450
  MAP_HEIGHT = 350
  MAP_OFFSET = 50
  TERRITORY_NODE_SIZE = 30

  def player_color(players, player)
    PLAYER_COLORS[players.find_index(player)]
  end

  def map_display(turn)
    content_tag("svg", class: "map-display", width: MAP_WIDTH, height: MAP_HEIGHT) do
      content_tag("g", map_display_content(turn), transform: translate(MAP_OFFSET))
    end
  end

  private

  def map_display_content(turn)
    (territory_link_lines(turn) + territory_nodes(turn)).join.html_safe
  end

  def territory_link_lines(turn)
    turn.game_state.territory_links.map do |link|
      content_tag("line", "",
        class: "link",
        x1: link[0].x,
        y1: link[0].y,
        x2: link[1].x,
        y2: link[1].y
      )
    end
  end

  def territory_nodes(turn)
    turn.game.territories.map.with_index do |territory, index|
      children = territory_node_content(territory, index, turn)

      content_tag("g", children, class: "node", transform: translate(territory.x, territory.y))
    end
  end

  def territory_node_content(territory, index, turn)
    color = player_color(turn.game.players, turn.game_state.territory_owner(territory))
    units = turn.game_state.units_on_territory(territory)

    [
      content_tag("circle", "", r: TERRITORY_NODE_SIZE, fill: color),
      content_tag("text", index, :"text-anchor" => "middle", :dy => -4),
      content_tag("text", "Units: #{units}", :"text-anchor" => "middle", :dy => 10)
    ].join.html_safe
  end

  def translate(x, y = x)
    "translate(#{x},#{y})"
  end
end
