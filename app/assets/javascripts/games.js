jQuery(function($) {
  var gameDisplay = $('#game-display');
  if (!gameDisplay.length) {
    return;
  }

  var BASE_WIDTH = 450;
  var BASE_HEIGHT = 350;

  var svg = d3.select(gameDisplay.get(0)).append("svg")
    .attr("class", "map-display")
    .attr("width", BASE_WIDTH)
    .attr("height", BASE_HEIGHT);

  var links = svg.selectAll(".link");
  var nodes = svg.selectAll(".node");

  var forceLayout = d3.layout.force()
      .size([BASE_WIDTH, BASE_HEIGHT])
      .charge(-1000)
      .linkDistance(100)
      .on("tick", onForceTick);

  var dragEvent = forceLayout.drag()
      .on("dragstart", onDragstart);

  function setupLinks(graphLinks) {
    links = links.data(graphLinks)
      .enter().append("line")
        .attr("class", "link");
  }

  function setupNodes(graphNodes, playerIds) {
    nodes = nodes.data(graphNodes)
      .enter().append("g")
        .attr("class", function(d) { return "node player-" + d.owner })
        .on("dblclick", onDblclick)
        .call(dragEvent);

    nodes.append("circle")
      .attr("r", 25);

    nodes.append("text")
      .attr("text-anchor", "middle")
      .attr("dy", "4px")
      .text(function(d) { return d.units });
  }

  d3.json(window.location.href + "/territory_info.json", function(error, info) {
    if (error) {
      throw error;
    }

    forceLayout
      .nodes(info.territories)
      .links(info.territory_links)
      .start();

    setupLinks(info.territory_links);
    setupNodes(info.territories);
  });

  function onForceTick() {
    links.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

    nodes.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
  }

  function onDblclick(d) {
    d3.select(this).classed("fixed", d.fixed = false);
  }

  function onDragstart(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }
});
