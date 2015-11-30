GameDisplay.playerView = ({ $container, state }) => {
  $container.html(`
    <div class="current-player"></div>

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

  function update(newState) {
    state = newState;

    $container.find(".current-player").text(state.players[state.currentPlayer].name + "'s turn");
  }

  update(state);

  return { update };
};
