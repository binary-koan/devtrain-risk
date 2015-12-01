window.AJAX = (function() {
  let ERROR_MESSAGES = {
    "no_link": "There isn't a link between those territories!",
    "wrong_player": "It's not your turn!",
    "own_territory": "You can't attack your own territory!",
    "cannot_attack_with_one_unit": "You can't attack unless you have more than one unit!"
  };

  function _displayErrors(...errors) {
    errors.forEach(error => {
      let message = ERROR_MESSAGES[error];
      $("<div>").text(message).appendTo($(".errors"));
    });
  }

  function _handleResponse({ response, resolve, reject }) {
    if (response.errors) {
      _displayErrors(...response.errors);
      reject(response.errors);
    }
    else {
      resolve(response);
    }
  }

  function _handleFailure({ error, reject }) {
    _displayErrors(error);
    reject(error);
  }

  function perform(type, ...args) {
    return new Promise((resolve, reject) => {
      jQuery[type](...args).then(
        (response) => _handleResponse({ response, resolve, reject }),
        (xhr, error) => _handleFailure({ error, reject })
      );
    });
  }

  return {
    perform,
    get:  _.partial(perform, "get"),
    post: _.partial(perform, "post")
  };
})();
