window.GameDisplay = window.GameDisplay || {};

GameDisplay.component = (container) => {
  let view;
  let state;

  let { performAction } = GameDisplay.component.actionManager({
    updateView: () => view.update()
  });

  function start() {
    d3.json(window.location.href + "/territory_info.json", (error, response) => {
      if (error) throw error;
      state = response;
      view = GameDisplay.view({ container, state, performAction });
    });
  }

  setTimeout(function() {
    // Pretend a request has come in with:
    var response = [{ index: 0, units: -2, owner: 0 }, { index: 1, units: 2, owner: 1 }];
    response.forEach(function(change) {
      state.territories[change.index].units += change.units;
      state.territories[change.index].owner = change.owner;
    });
    view.update();
  }, 5000);

  return { start };
};

GameDisplay.component.actionManager = ({ updateView }) => {
  const ACTION_STATE = { NONE: 0, STARTED: 1 };

  let currentState = ACTION_STATE.NONE;

  function performAction(d) {
    if (currentState === ACTION_STATE.STARTED) {
      // Do something
    }
    else {
      currentState = ACTION_STATE
    }
  }

  return { performAction };
}
