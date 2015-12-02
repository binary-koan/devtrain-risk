GameDisplay.playerView = ({ $container, onTurnEnded }) => {
  let state;

  let $endTurnButton = $("<button>").text("End turn").appendTo($container);

  function update(newState) {
    state = newState;

    $container.html(`
      <div class="current-player">
        ${state.players[state.currentPlayer].name}'s turn
      </div>

      <div class="player-display">
        <div class="player-0">
          <span class="player-icon player-0"></span>
          ${state.players[0].name}
        </div>

        <div class="player-1">
          <span class="player-icon player-1"></span>
          ${state.players[1].name}
        </div>
      </div>
    `);
  }

  $endTurnButton.click(onTurnEnded);

  return { update };
};
