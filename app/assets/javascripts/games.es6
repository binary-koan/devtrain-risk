function displayErrors(errors) {
  let messageSection = $(".messages").html("");

  errors.forEach(error => $("<div>").text(error).appendTo(messageSection));
}

$(document.body).on("submit", "form.new_event", event => {
  event.preventDefault();

  let form = $(event.target);

  form.find("[type=submit]").attr("disabled", true).html("<div class='progress'><div>Loading…</div></div>");

  $("form.new_event").addClass("hidden");
  form.removeClass("hidden");

  $.post(form.attr("action"), form.serializeArray(), data => {
    if (data.errors) {
      displayErrors(data.errors);
    } else {
      $("#game-display").html(data.content);
    }
  });
});
