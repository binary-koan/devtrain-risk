window.GameDisplay = window.GameDisplay || {};

GameDisplay.boardView = ({ $container, onActionPerformed }) => {
  const BASE_WIDTH = 450;
  const BASE_HEIGHT = 350;

  let state;

  const svg = d3.select($container.get(0)).append("svg");
  let links;
  let nodes;

  function _initialize() {
    links = svg.selectAll(".link").data(state.territoryLinks).enter().append("line");
    nodes = svg.selectAll(".node").data(state.territories).enter().append("g");

    links.attr("x1", d => state.territories[d.source].x + 50)
      .attr("y1", d => state.territories[d.source].y + 50)
      .attr("x2", d => state.territories[d.target].x + 50)
      .attr("y2", d => state.territories[d.target].y + 50);

    nodes.attr("transform", d => `translate(${d.x + 50},${d.y + 50})`);

    links.attr("class", "link");

    nodes.append("circle")
      .attr("r", 25);

    nodes.append("text")
      .attr("text-anchor", "middle")
      .attr("dy", "4px");

    nodes.on("click", function(d) {
      d3.select(this).classed("active", true);
      onActionPerformed(d);
    });

    _updateNodeContent();
  }

  function _updateNodeContent() {
    nodes.data(state.territories);
    nodes.attr("class", d => `node player-${d.owner}`)
    nodes.select("text").text(d => d.units);
  }

  function update(newState) {
    if (!state) {
      state = newState;
      _initialize();
    }
    else {
      state = newState;
    }

    _updateNodeContent();
  }

  function clear() {
    nodes.classed("active", false);
  }

  svg.attr("class", "map-display")
    .attr("width", BASE_WIDTH)
    .attr("height", BASE_HEIGHT);

  return { update, clear };
};
