window.GameDisplay = window.GameDisplay || {};

GameDisplay.component = (container) => {
  let view;
  let state;

  let { performAction } = GameDisplay.component.actionManager({ applyActions });

  function _updateState(callback) {
    $.get(window.location.href + "/state.json").done((response) => {
      state = response.state;
      callback(response);
    });
  }

  function applyActions(actions) {
    _updateState(_.partial(view.update, state));
  }

  function start() {
    //TODO error handling
    _updateState(() => view = GameDisplay.view({ container, state, performAction }));
  }

  return { start };
};

GameDisplay.component.actionManager = ({ applyActions }) => {
  const ACTION_STATE = { NONE: 0, STARTED: 1 };

  let currentState = ACTION_STATE.NONE;
  let activeNodeId;

  function _doRequest(data) {
    //TODO error handling
    $.post(window.location.href + "/event.json", data).done(applyActions);
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
