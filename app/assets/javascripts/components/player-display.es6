function PlayerDisplay({ DOM, HTTP }) {
  const { h } = CycleDOM;

  function playerViewClass(state, index) {
    let baseClassName = `player-${index}`;
    return baseClassName + (state.currentPlayer == index ? " current" : "");
  }

  function playerView(state, player, index) {
    return h("div", { className: playerViewClass(state, index) }, [
      h("span.player-icon"),
      player.name
    ]);
  }

  const view$ = HTTP
    .mergeAll()
    .map(res => JSON.parse(res.text).state)
    .filter(Boolean)
    .map(state =>
      h(".player-display", state.players.map(playerView.bind(null, state)))
    );

  return { DOM: view$ };
}
