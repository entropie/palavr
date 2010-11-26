
function debug(msg) {
  //$('#debug').append("<p>" + msg + "</p>");
  console.log && console.log(msg);
};


spinner = "<div class=\"spinner\"><img src=\"/img/spinner.gif\" /></div>";

(function( $ ){

   $.fn.mk_tags = function(){
     var allTags;
     var tags = [];
     $(this).find(".tags span").each(function(){
       tags.push($(this).html());
     });

     $.ajax({
       type: "GET",
       url: "/t/all",
       success: function(data){
         $("#mytags").tagit({
           startingTags: tags,
           availableTags: data.split(" ")
         });
       },
       complete: function(){
       }
     });



   },

  $.fn.toggleHelp = function(){
    $(this).click(function(){
      $.ajax({
        type: "GET",
        url: "/help",
        success: function(data){
          $.modal(data, {
                    overlayClose:true,
                    maxWidth:"60%",
                    minHeight:"60%",
                    autoResize: true,
                    opacity: 90
          });
        },
        complete: function(){
        }
      });
      return false;
    });
  };

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
        var index = $(body).find(".para").index(p);
        var rest = $(body).find(".para:gt(" + index + ")");
        $(".moar", p).find("a").click(function(){
          var link = $(this);
          link.hide();
          $(p).append(spinner);
          rest.toggleClass("dim");
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
                $(p).find(".subphread").slideUp(function(){ $(this).remove(); link.fadeIn(); rest.toggleClass("dim"); });
              });
            }
          });
        });
      });
    });
  };


})(jQuery);

google.setOnLoadCallback(function() {

  $("#helplink").toggleHelp();

  if($("#phread").length){
    $(".tagline").mk_tags();
    $("#phread").mk_chapterLinks();
    $("#phread").mk_like();
  };

});
