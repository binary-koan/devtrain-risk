//= require ./animate-diff

function wrapGameDisplay(selector) {
  function element() {
    return $(selector);
  }

  function elementHTML() {
    return $(selector).get(0).outerHTML;
  }

  function showLoadingSpinner(form) {
    form.find("input, select, button").attr("disabled", true);
    form.find("[type=submit]").html("<div class='progress'><div>Loading…</div></div>");
  }

  function hideOthers(selector, exception) {
    $(selector).addClass("hidden");
    exception.removeClass("hidden");
  }

  function withLoadingState(form, deferred) {
    let cache = element().clone();

    showLoadingSpinner(form);
    hideOthers("form.new_event", form);

    return deferred.always(() => element().replaceWith(cache));
  }

  function update(newContent) {
    let previousDisplay = element().replaceWith(newContent);
    animateDiff(previousDisplay, element());
  }

  return { withLoadingState, update };
}
