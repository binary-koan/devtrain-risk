//= require ./components/map-display
//= require ./components/player-display

function GameDisplay(responses) {
  const { h } = CycleDOM;

  const map = MapDisplay(responses);
  const players = PlayerDisplay(responses);

  const view$ = Rx.Observable.combineLatest([map.DOM, players.DOM], (...components) =>
    h("div", components)
  );

  return {
    DOM: view$,
    HTTP: map.HTTP
  };
}

if (document.getElementById("game-display")) {
  Cycle.run(GameDisplay, {
    DOM: CycleDOM.makeDOMDriver("#game-display"),
    HTTP: CycleHTTPDriver.makeHTTPDriver()
  });
}
