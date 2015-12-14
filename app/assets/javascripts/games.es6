//= require game-display/animate-diff

jQuery(function($) {
  function displayErrors(errors) {
    let messageSection = $(".messages").html("");

    errors.forEach(error => $("<div>").text(error).appendTo(messageSection));
  }

  function showLoadingSpinner(form) {
    form.find("[type=submit]")
      .attr("disabled", true)
      .html("<div class='progress'><div>Loading…</div></div>");
  }

  function hideOthers(selector, exception) {
    $(selector).addClass("hidden");
    exception.removeClass("hidden");
  }

  function updateGameDisplay(data) {
    if (data.errors) {
      displayErrors(data.errors);
    } else {
      let oldGameDisplay = $("#game-display").replaceWith(data.content);
      GameDisplay.animateDiff(oldGameDisplay, $("#game-display"));
    }
  }

  function submitForm(form) {
    showLoadingSpinner(form);
    hideOthers("form.new_event", form);

    $.post(form.attr("action"), form.serializeArray(), updateGameDisplay);
  }

  $(document.body).on("submit", "form.new_event", event => {
    event.preventDefault();
    submitForm($(event.target));
  });
});
