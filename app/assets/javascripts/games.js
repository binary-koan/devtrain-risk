jQuery(function($) {
  var $container = $("#game-display");
  if ($container.length) {
    GameDisplay.component($container).start();
  }
});
