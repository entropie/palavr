function debug(msg) {
  $('#debug').append("<p>" + msg + "</p>");
};

google.setOnLoadCallback(function() {
                           debug("foo");
                           debug("bar");
});
