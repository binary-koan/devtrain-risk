function wrapMessageSection(selector) {
  function element() {
    return $(selector);
  }

  function clear() {
    element().html("");
  }

  function display(messages, type) {
    clear();

    element().append(messages.map(message =>
      $("<div>").addClass(`${type} message`).text(message)
    ));
  }

  return { clear, display };
}
