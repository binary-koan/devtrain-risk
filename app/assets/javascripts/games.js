jQuery(function($) {
  var container = document.querySelector("#game-display");
  if (container) {
    GameDisplay.component(container).start();
  }
});
