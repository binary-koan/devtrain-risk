//= require ./components/map-display
//= require ./components/player-display
//= require ./components/forms/attack-form

function GameDisplay(responses) {
  const { h } = CycleDOM;

  const map = MapDisplay(responses);
  const players = PlayerDisplay(responses);

  const attackForm = AttackForm(responses);

  const view$ = Rx.Observable.combineLatest([map.DOM, players.DOM, attackForm.DOM], (...components) =>
    h("div", components)
  );

  return {
    DOM: view$,
    HTTP: Rx.Observable.merge(map.HTTP, attackForm.HTTP)
  };
}

if (document.getElementById("game-display")) {
  Cycle.run(GameDisplay, {
    DOM: CycleDOM.makeDOMDriver("#game-display"),
    HTTP: CycleHTTPDriver.makeHTTPDriver()
  });
}
