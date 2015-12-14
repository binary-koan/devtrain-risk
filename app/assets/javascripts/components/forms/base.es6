function uid(prefix) {
  return prefix + "-" + Math.random().toString(16).substr(2);
}

function createFormComponent(eventType, { view }) {
  const { h } = CycleDOM;
  const { filter, find } = _;

  function createHelpers({ action, state }) {
    return {
      ownedTerritoriesSelect() { },
      enemyTerritoriesSelect() { }
    }
  }

  return ({ DOM, HTTP }) => {
    const formId = "#" + uid("form");

    const ownedTerritories$ = HTTP.mergeAll()
      .map(res => JSON.parse(res.text).state)
      .filter(Boolean)
      .map(state =>
        filter(state.territories, territory => territory.owner === state.currentPlayer)
      );

    const view$ = HTTP.mergeAll()
      .map(res => JSON.parse(res.text))
      .filter(data => data.allowedActions)
      .map(data => ({
        action: find(data.allowedActions, action => action.eventType === eventType),
        state: data.state
      }))
      .map(data =>
        h(formId, view(createHelpers(data)))
      );

    const request$ = DOM.select(`${formId} *[type=submit]`).events("click")
      .map(_ => ({ method: "POST", url: location.href + "/events" }));

    return { DOM: view$.startWith(""), HTTP: request$ };
  };
}
