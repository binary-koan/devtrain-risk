let GameDisplay = GameDisplay || {};

function animateDiff(previousDOM, currentDOM) {
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
        return { difference: currUnits - prevUnits, remaining: currUnits, element: unitsDisplay };
      }
    });

    return differences.toArray().filter(Boolean);
  }

  function showAnimatedIcon(name, element) {
    let bbox = element.get(0).getBBox();
    bbox = pick(bbox, "x", "y", "width", "height");

    let icon = $(document.createElementNS("http://www.w3.org/2000/svg", "use"));
    icon.attr(bbox).attr("class", `icon animated ${name}`);
    icon[0].setAttributeNS("http://www.w3.org/1999/xlink", "href", `#icon-${name}`);

    // icon.on("animationend", () => icon.remove());

    element.append(icon);
  }

  function isFortify(differences) {
    return differences.length === 2 &&
      differences[0].difference < 0 && differences[1].difference > 0;
  }

  function getIconNames(differences) {
    if (isFortify(differences)) {
      return ["fortify-away", "fortify"];
    } else {
      return differences.map(item => {
        if (item.remaining === 0) {
          return "explosion-large";
        } else if (item.difference < 0) {
          return "explosion-small";
        } else {
          return "fortify";
        }
      });
    }
  }

  let sortedDifferences = findDifferences()
    .sort((a, b) => a.difference - b.difference);

  let iconNames = getIconNames(sortedDifferences);

  sortedDifferences.forEach((item, index) => {
    showAnimatedIcon(iconNames[index], $(item.element).closest("g"));
  });
};
