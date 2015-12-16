//= require ./game-display/game-display
//= require ./messages

{
  let gameDisplay = wrapGameDisplay("#game-display");
  let messageSection = wrapMessageSection(".messages");

  function updateGameDisplay(data) {
    if (data.errors) {
      messageSection.display(data.errors, "error");
    } else {
      messageSection.clear();
      gameDisplay.update(data.content);
    }
  }

  function submitForm(form) {
    let xhr = $.post(form.attr("action"), form.serializeArray());

    gameDisplay.withLoadingState(form, xhr).then(updateGameDisplay);
  }

  $(document.body).on("submit", "form.new_event", event => {
    event.preventDefault();
    submitForm($(event.target));
  });
}
