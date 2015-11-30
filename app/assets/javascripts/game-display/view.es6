window.GameDisplay = window.GameDisplay || {};

GameDisplay.view = ({ container, state, performAction }) => {
  const BASE_WIDTH = 450;
  const BASE_HEIGHT = 350;

  const svg = d3.select(container).append("svg");
  const links = svg.selectAll(".link").data(state.territoryLinks).enter().append("line");
  const nodes = svg.selectAll(".node").data(state.territories).enter().append("g");

  const layout = d3.layout.force();

  GameDisplay.view.enableDragging({ layout, nodes });

  function _updateNodeContent() {
    nodes.attr("class", function(d) { return "node player-" + d.owner })
    nodes.select("text").text(function(d) { return d.units });
  }

  function update(newState) {
    state = newState;
    _updateNodeContent();
  }

  // Layout

  layout.size([BASE_WIDTH, BASE_HEIGHT])
    .charge(-1000)
    .linkDistance(100)
    .nodes(state.territories)
    .links(state.territoryLinks)
    .start();

  svg.attr("class", "map-display")
    .attr("width", BASE_WIDTH)
    .attr("height", BASE_HEIGHT);

  // Elements

  links.attr("class", "link");

  nodes.append("circle")
    .attr("r", 25);

  nodes.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", "4px");

  _updateNodeContent();

  // Events

  layout.on("tick", () => {
    links.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

    nodes.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
  });

  nodes.on("click", performAction);

  return { update };
};

GameDisplay.view.enableDragging = ({ layout, nodes }) => {
  const drag = layout.drag();

  function _setFixedOn(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }

  function _setFixedOff(d) {
    d3.select(this).classed("fixed", d.fixed = false);
  }

  drag.on("dragstart", _setFixedOn);
  nodes.on("dblclick", _setFixedOff).call(drag);
  layout.on("end", _.once(() => nodes.each(_setFixedOn)));
};
