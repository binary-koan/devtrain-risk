jQuery(function($) {
  var container = $('#game-display');
  if (!container) {
    return;
  }

  var svg = d3.select(container.get(0)).append("svg");

  var display = {
    BASE_WIDTH: 450,
    BASE_HEIGHT: 350,

    links: svg.selectAll(".link"),
    nodes: svg.selectAll(".node"),

    layout: d3.layout.force(),
  };

  var state = {};

  var setup = {
    base: function() {
      svg.attr("class", "map-display")
        .attr("width", display.BASE_WIDTH)
        .attr("height", display.BASE_HEIGHT);

      display.layout.size([display.BASE_WIDTH, display.BASE_HEIGHT])
        .charge(-1000)
        .linkDistance(100);
    },

    layout: function() {
      display.layout.nodes(state.territories).links(state.territoryLinks).start();
    },

    links: function() {
      display.links = display.links.data(state.territoryLinks)
        .enter().append("line")
          .attr("class", "link");
    },

    nodes: function() {
      display.nodes = display.nodes.data(state.territories)
        .enter().append("g");

      display.nodes.append("circle")
        .attr("r", 25);

      display.nodes.append("text")
        .attr("text-anchor", "middle")
        .attr("dy", "4px");

      update.nodes();
    },

    events: function() {
      function updateGraph() {
        display.links.attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; });

        display.nodes.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
      }

      function setFixedOff(d) {
        d3.select(this).classed("fixed", d.fixed = false);
      }

      function setFixedOn(d) {
        d3.select(this).classed("fixed", d.fixed = true);
      }

      var dragEvent = display.layout.drag().on("dragstart", setFixedOn);

      display.layout.on("tick", updateGraph).on("end", function() {
        display.nodes.each(setFixedOn);
      });

      display.nodes.on("dblclick", setFixedOff).call(dragEvent);
    }
  };

  var update = {
    nodes: function() {
      display.nodes.attr("class", function(d) { return "node player-" + d.owner })
      display.nodes.select("text").text(function(d) { return d.units });
    }
  };

  d3.json(window.location.href + "/territory_info.json", function(error, response) {
    if (error) {
      throw error;
    }

    state = response;

    setup.base();
    setup.layout();
    setup.links();
    setup.nodes();
    setup.events();
  });

  setTimeout(function() {
    // Pretend a request has come in with:
    var response = [{ index: 0, units: -2, owner: 0 }, { index: 1, units: 2, owner: 1 }];
    response.forEach(function(change) {
      state.territories[change.index].units += change.units;
      state.territories[change.index].owner = change.owner;
    });
    update.nodes();
  }, 5000);
});
