//= require ./base

const AttackForm = createFormComponent("attack", {
  view(helpers) {
    const { h } = CycleDOM;

    return h("form", [
      h("field[type=hidden][name=event_type]", { value: "attack" }),
      "Attack with",
      h("field[type=number][name=units]"),
      " units from ",
      helpers.ownedTerritoriesSelect("from"),
      " to ",
      helpers.enemyTerritoriesSelect("to"),
      h("button.icon-button[type=submit]", [
        h("span.icon.attack"), " Attack"
      ])
    ]);
  }
});
