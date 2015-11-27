window.GameDisplay = window.GameDisplay || {};

GameDisplay.component = (container) => {
  let view;
  let state;

  let { performAction } = GameDisplay.component.actionManager({ applyActions });

  function _patchState(actions) {
    console.log(actions);
    actions.forEach(action => {
      state.territories[action.territoryIndex].units += action.units;
      state.territories[action.territoryIndex].owner = action.ownerIndex;
    });
  }

  function applyActions(actions) {
    _patchState(actions);
    view.update(state);
  }

  function start() {
    //TODO error handling
    $.get(window.location.href + "/territory_info.json").done((response) => {
      state = response;
      view = GameDisplay.view({ container, state, performAction });
    });
  }

  // setTimeout(function() {
  //   // Pretend a request has come in with:
  //   var response = [{ index: 0, units: -2, owner: 0 }, { index: 1, units: 2, owner: 1 }];
  //   response.forEach(function(change) {
  //     state.territories[change.index].units += change.units;
  //     state.territories[change.index].owner = change.owner;
  //   });
  //   view.update();
  // }, 5000);

  return { start };
};

GameDisplay.component.actionManager = ({ applyActions }) => {
  const ACTION_STATE = { NONE: 0, STARTED: 1 };

  let currentState = ACTION_STATE.NONE;
  let activeNodeId;

  function _doRequest(data) {
    //TODO error handling
    $.post(window.location.href + "/event.json", data).done(response => {
      applyActions(response.actions);
    });
  }

  function _finishAction(node) {
    if (node.id !== activeNodeId) {
      console.log("doing json");
      _doRequest({ type: "attack", from: activeNodeId, to: node.id });
    }

    currentState = ACTION_STATE.NONE;
  }

  function performAction(node) {
    if (currentState === ACTION_STATE.STARTED) {
      _finishAction(node);
    }
    else {
      currentState = ACTION_STATE.STARTED;
      activeNodeId = node.id;
    }
  }

  return { performAction };
}
