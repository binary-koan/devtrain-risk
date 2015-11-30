window.GameDisplay = window.GameDisplay || {};

GameDisplay.component = ($container) => {
  let boardView, playerView;
  let state;

  let { onActionPerformed } = GameDisplay.component.actionManager({ onActionSucceeded: updateAll });

  function _updateState(callback) {
    $.get(window.location.href + "/state.json").done((response) => {
      state = response.state;
      callback(response);
    });
  }

  function updateAll() {
    _updateState(() => {
      boardView.update(state);
      playerView.update(state);
    });
  }

  function onTurnEnded() {
    $.post(location.href + "/end_turn.json").done(updateAll);
  }

  function start() {
    //TODO error handling
    _updateState(() => {
      let boardContainer = $("<div>").appendTo($container);
      boardView = GameDisplay.boardView({ $container: boardContainer, state, onActionPerformed });
      let playerContainer = $("<div>").appendTo($container);
      playerView = GameDisplay.playerView({ $container: playerContainer, state, onTurnEnded });
    });
  }

  return { start };
};

GameDisplay.component.actionManager = ({ onActionSucceeded }) => {
  const ACTION_STATE = { NONE: 0, STARTED: 1 };

  let currentState = ACTION_STATE.NONE;
  let activeNodeId;

  function _doRequest(data) {
    //TODO error handling
    $.post(window.location.href + "/event.json", data).done(onActionSucceeded);
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
