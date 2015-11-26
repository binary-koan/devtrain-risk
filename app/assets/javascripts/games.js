//TODO JSON!
jQuery(function($) {
  if (!window.GAME_STATE) {
    return;
  }

  var width = 450,
      height = 350;

  var force = d3.layout.force()
      .size([width, height])
      .charge(-1000)
      .linkDistance(100)
      .on("tick", tick);

  var drag = force.drag()
      .on("dragstart", dragstart);

  var svg = d3.select("body").append("svg")
      .attr("class", "map-display")
      .attr("width", width)
      .attr("height", height);

  var link = svg.selectAll(".link"),
      node = svg.selectAll(".node");

// d3.json("graph.json", function(error, graph) {
  // if (error) throw error;

  var idMappings = {};
  var nodes = [];
  Object.keys(GAME_STATE.territories).forEach(function(key) {
    idMappings[key] = nodes.length;
    nodes.push(GAME_STATE.territories[key]);
  });

  var links = GAME_STATE.territory_links.map(function(link) {
    return { source: idMappings[link.from.toString()], target: idMappings[link.to.toString()] };
  });

  var graph = {
    nodes: nodes,
    links: links
  };

  force
    .nodes(graph.nodes)
    .links(graph.links)
    .start();

  link = link.data(graph.links)
    .enter().append("line")
      .attr("class", "link");

  var playerIds = Object.keys(GAME_STATE.players);
  node = node.data(graph.nodes)
    .enter().append("g")
      .attr("class", function(d) { return "node player-" + playerIds.indexOf(d.owner.toString()); })
      .on("dblclick", dblclick)
      .call(drag);
// });

  node.append("circle")
    .attr("r", 25);

  node.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", "4px")
    .text(function(d) { return d.units });

  function tick() {
    link.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

    node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
  }

  function dblclick(d) {
    d3.select(this).classed("fixed", d.fixed = false);
  }

  function dragstart(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }
});
