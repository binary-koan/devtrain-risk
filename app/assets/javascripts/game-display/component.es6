window.GameDisplay = window.GameDisplay || {};

GameDisplay.component = ($container) => {
  let boardView, playerView;
  let state;

  let { onActionPerformed } = GameDisplay.component.actionManager({
    onActionSucceeded: updateViews,
    onActionFailed: clearViews
  });

  function _updateState(callback) {
    AJAX.get(window.location.href + "/state.json").then((response) => {
      state = response.state;
      callback(response);
    });
  }

  function updateViews() {
    _updateState(() => {
      boardView.update(state);
      playerView.update(state);
    });
  }

  function clearViews() {
    boardView.clear();
  }

  function onTurnEnded() {
    AJAX.post(location.href + "/end_turn.json").then(updateViews);
  }

  function start() {
    _updateState(() => {
      let boardContainer = $("<div>").appendTo($container);
      boardView = GameDisplay.boardView({ $container: boardContainer, state, onActionPerformed });
      let playerContainer = $("<div>").appendTo($container);
      playerView = GameDisplay.playerView({ $container: playerContainer, state, onTurnEnded });
    });
  }

  return { start };
};

GameDisplay.component.actionManager = ({ onActionSucceeded, onActionFailed }) => {
  const ACTION_STATE = { NONE: 0, STARTED: 1 };

  let currentState = ACTION_STATE.NONE;
  let activeNodeId;

  function _doRequest(data) {
    AJAX.post(window.location.href + "/event.json", data).then(onActionSucceeded, onActionFailed);
  }

  function _finishAction(node) {
    if (node.id !== activeNodeId) {
      _doRequest({ type: "attack", from: activeNodeId, to: node.id });
    }

    currentState = ACTION_STATE.NONE;
  }

  function onActionPerformed(node) {
    if (currentState === ACTION_STATE.STARTED) {
      _finishAction(node);
    }
    else {
      currentState = ACTION_STATE.STARTED;
      activeNodeId = node.id;
    }
  }

  return { onActionPerformed };
}
