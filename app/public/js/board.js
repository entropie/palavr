
function debug(msg) {
  //$('#debug').append("<p>" + msg + "</p>");
  console.log && console.log(msg);
};


spinner = "<div class=\"spinner\"><img src=\"/img/spinner.gif\" /></div>";

(function( $ ){
  $.fn.mk_like = function() {
    var p = $(this);
    var ll = $(this).find(".like_link");
    var url = ll.attr("href");
    ll.click(function(){
      ll.html(spinner);
      $.ajax({
        type: "GET",
        url: url,
        success: function(data){
          ll.parent().html(data);
        },
        complete: function(){
          ll.unbind("click");
          $(p).mk_like();
        }
      });
      return false;
    });
  };

  $.fn.mk_chapterLinks = function() {
    $(this).each(function(){
      var body = $(".body", this);
      body.find(".para").each(function(){
        var p = this;
        var phreadid = body.attr("id").split("_")[1];
        var url = "/s/phreads_for/" + phreadid + "/" + $(this).attr("id") + "?offset=0";

        $(".moar", p).find("a").click(function(){
          var link = $(this);
          link.hide();
          $(p).append(spinner);
          $.ajax({
            type: "GET",
            url: url,
            success: function(data){
              $(p).append(data);
            },
            complete: function(){
              $(p).find(".inv").slideDown("slow");
              $(p).find(".spinner").fadeOut();
              $(p).find(".x").click(function(){
                $(p).find(".subphread").slideUp(function(){ $(this).remove(); link.fadeIn(); });
              });
            }
          });
        });
      });
    });
  };


})(jQuery);


google.setOnLoadCallback(function() {

  if($("#phread").length){
    $("#phread").mk_chapterLinks();
    $("#phread").mk_like();
  };

});
