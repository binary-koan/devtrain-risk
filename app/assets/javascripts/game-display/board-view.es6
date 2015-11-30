window.GameDisplay = window.GameDisplay || {};

GameDisplay.boardView = ({ $container, state, onActionPerformed }) => {
  const BASE_WIDTH = 450;
  const BASE_HEIGHT = 350;

  const svg = d3.select($container.get(0)).append("svg");
  const links = svg.selectAll(".link").data(state.territoryLinks).enter().append("line");
  const nodes = svg.selectAll(".node").data(state.territories).enter().append("g");

  const layout = d3.layout.force();

  GameDisplay.boardView.enableDragging({ layout, nodes });

  function _updateNodeContent() {
    nodes.attr("class", d => `node player-${d.owner}`)
    nodes.select("text").text(d => d.units);
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
    links.attr("x1", d => d.source.x)
      .attr("y1", d => d.source.y)
      .attr("x2", d => d.target.x)
      .attr("y2", d => d.target.y);

    nodes.attr("transform", d => `translate(${d.x},${d.y})`);
  });

  nodes.on("click", function(d) {
    d3.select(this).classed("active", true);
    onActionPerformed(d);
  });

  return { update };
};

GameDisplay.boardView.enableDragging = ({ layout, nodes }) => {
  const drag = layout.drag();

  function _setFixedOn(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }

  function _setFixedOff(d) {
    d3.select(this).classed("fixed", d.fixed = false);
  }

  drag.on("dragstart", _setFixedOn);
  nodes.on("dblclick", _setFixedOff).call(drag);
};
