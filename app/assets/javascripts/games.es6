//= require game-display/animate-diff

jQuery(function($) {
  let oldGameDisplay;

  function cacheGameDisplay() {
    oldGameDisplay = $("#game-display").get(0).outerHTML;
  }

  function restoreGameDisplay() {
    $("#game-display").replaceWith(oldGameDisplay);
  }

  function displayErrors(errors) {
    let messageSection = $(".messages").html("");

    errors.forEach(error => $("<div>").text(error).appendTo(messageSection));
  }

  function showLoadingSpinner(form) {
    form.find("input, select, button").attr("disabled", true);
    form.find("[type=submit]").html("<div class='progress'><div>Loading…</div></div>");
  }

  function hideOthers(selector, exception) {
    $(selector).addClass("hidden");
    exception.removeClass("hidden");
  }

  function updateGameDisplay(data) {
    if (data.errors) {
      displayErrors(data.errors);
      restoreGameDisplay();
    } else {
      let previousDisplay = $("#game-display").replaceWith(data.content);
      GameDisplay.animateDiff(previousDisplay, $("#game-display"));
    }
  }

  function submitForm(form) {
    let data = form.serializeArray();

    showLoadingSpinner(form);
    hideOthers("form.new_event", form);

    $.post(form.attr("action"), data, updateGameDisplay);
  }

  $(document.body).on("submit", "form.new_event", event => {
    event.preventDefault();
    cacheGameDisplay();
    submitForm($(event.target));
  });
});
