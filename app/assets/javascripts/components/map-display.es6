function MapDisplay({ HTTP }) {
  const TERRITORY_NODE_SIZE = 30;

  const { h, svg } = CycleDOM;
  const { pluck, min, max } = _;

  function viewbox(territories) {
    const xValues = pluck(territories, "x");
    const yValues = pluck(territories, "y");
    const offset = TERRITORY_NODE_SIZE;

    return `${min(xValues) - offset} ${min(yValues) - offset} ` +
      `${max(xValues) + offset * 2} ${max(yValues) + offset * 2}`;
  }

  function territoryLink(link, territories) {
    return svg("line", {
      class: "link",
      x1: territories[link.from].x,
      y1: territories[link.from].y,
      x2: territories[link.to].x,
      y2: territories[link.to].y
    });
  }

  function territoryNode(territory) {
    return svg("g", {
      class: `territory player-${territory.owner}`,
      transform: `translate(${territory.x},${territory.y})`
    }, [
      svg("image", {
        "xlink:href": "/assets/planet.png",
        x: -TERRITORY_NODE_SIZE,
        y: -TERRITORY_NODE_SIZE,
        width: TERRITORY_NODE_SIZE * 2,
        height: TERRITORY_NODE_SIZE * 2
      }),
      svg("circle", { r: TERRITORY_NODE_SIZE }),
      svg("text", { "text-anchor": "middle", dy: -3 }, territory.name),
      svg("text", { "text-anchor": "middle", dy: 12 }, `${territory.units} units`)
    ]);
  }

  const view$ = HTTP
    .mergeAll()
    .map(res => JSON.parse(res.text).state)
    .filter(Boolean)
    .map(state =>
      svg("svg", { class: "map-display", viewBox: viewbox(state.territories) }, [
        state.territoryLinks.map(link => territoryLink(link, state.territories)),
        state.territories.map(territory => territoryNode(territory))
      ])
    );

  const request$ = Rx.Observable.just(`${location.href}.json`);

  return { DOM: view$, HTTP: request$ };
}
