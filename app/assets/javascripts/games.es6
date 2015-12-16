//= require ./game-display/game-display

jQuery(function($) {
  let gameDisplay = createGameDisplay("#game-display");

  function displayErrors(errors) {
    let messageSection = $(".messages").html("");

    errors.forEach(error => $("<div>").text(error).appendTo(messageSection));
  }

  function updateGameDisplay(data) {
    if (data.errors) {
      displayErrors(data.errors);
    } else {
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
});
