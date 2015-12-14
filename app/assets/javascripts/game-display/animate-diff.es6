let GameDisplay = GameDisplay || {};

GameDisplay.animateDiff = (previousDOM, currentDOM) => {
  const { extend, pick } = _;

  const UNITS_MATCHER = /^\d+/;

  function pairedUnits(prevUnitDisplay, currUnitDisplay) {
    let displays = [prevUnitDisplay.text(), currUnitDisplay.text()];

    return displays.map(display => parseInt(UNITS_MATCHER.exec(display)[0]));
  }

  function findDifferences() {
    let prevUnitDisplays = previousDOM.find(".units-display");

    let differences = currentDOM.find(".units-display").map((i, unitsDisplay) => {
      let [prevUnits, currUnits] = pairedUnits(prevUnitDisplays.eq(i), $(unitsDisplay));

      if (prevUnits !== currUnits) {
        return { difference: currUnits - prevUnits, element: unitsDisplay };
      }
    });

    return differences.toArray().filter(Boolean);
  }

  function showAnimatedIcon(name, element) {
    let bbox = element.get(0).getBBox();
    bbox = pick(bbox, "x", "y", "width", "height");

    let icon = $(document.createElementNS("http://www.w3.org/2000/svg", "use"));
    icon.attr(bbox).attr("class", "icon-animated");
    icon[0].setAttributeNS("http://www.w3.org/1999/xlink", "href", `#icon-${name}`);

    element.append(icon);
  }

  let sortedDifferences = findDifferences()
    .sort((a, b) => a.difference - b.difference);

  sortedDifferences.forEach(item => {
    let icon = item.difference < 0 ? "explosion-small" : "fortify";
    showAnimatedIcon(icon, $(item.element).closest("g"));
  });

  console.log(sortedDifferences);
};
