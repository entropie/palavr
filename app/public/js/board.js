
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

     var phreadid = $(this).find("label").attr("id").split("_")[1];

     $.ajax({
       type: "GET",
       url: "/t/all",
       success: function(data){

         $("#mytags").tagit({
           startingTags: tags,
           availableTags: data.split(" "),
           onAdd: function(tag){
             $.ajax({
               type: "GET",
               url: "/t/phread/add/" + phreadid + "/" + tag
             });
           },
           onRemove: function(tag){
             $.ajax({
               type: "GET",
               url: "/t/phread/remove/" + phreadid + "/" + tag
             });
           }
         });
       },

       complete: function(){
       }
     });
   };

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

  $.fn.mk_loginForm = function(){
    var t = $(this);
    $(this).find(".link").click(function(){
      $(t).find(".email").append("<div class='spinner'>" + spinner + "</div>");
      $(t).find(".regform").slideDown();
      if($(t).find(".regform:visible").length)
        $(t).checkAvailability();
      $(this).unbind("click").slideUp();
      return false;
    });

    if($(t).find(".regform:visible").length)
      $(t).checkAvailability();
  };

   $.fn.setupUplink = function(){
     var app =  "<div class=\'inv app\'><ul>";
     var uid =$(this).find(".uplink").attr("href").split("/").reverse()[0];
     app += "<li class='pm'><a href='#/pm/" + uid + "'>Personal Message</a></li>";
     app += "<li class='stry'><a href='#/s/from/" +uid+ "'>All Stories</a></li>";
     app += "</ul></div>";
     $(this).hover(function(){
       $(this).append(app);
       $(this).find(".app").delay(800).fadeIn();
     }, function(){
       $(this).find(".app").remove();
       $(this).removeClass("act");
     });
   };


  $.fn.checkAvailability = function() {
    $("#username").change(function() {
    if ( $('#username').attr("value") != '') {
      $(".nick").find("input").removeClass("valid");
      $(".nick").find("input").removeClass("invalid");
      $('.spinner').fadeIn();
      var username = $('#username').val().toLowerCase();
      $.get("/auth/check_username", { username:username } , function(data) {
        if (data == 0) {
          $(".nick").find("input").addClass("invalid");
          $('.spinner').hide();
          $('.error').remove();
          $('.available').remove();
          $('#username').after('<span class="error"></span>');
          $('.error').text('Username is already taken.');
        } else {
          $(".nick").find("input").addClass("valid");
          $('.spinner').hide();
          $('.error').remove();
          $('.available').remove();
          $('#username').after('<span class="available"></span>');
          $('span.available').text('Username is available.');
        }
      });
    }
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

  $.fn.mkHelp = function() {
    $(".ttip").tooltip({
      showURL: false,
      left: 50,
      top: -10
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
    if($(".tagline").length)
      $(".tagline").mk_tags();
    $("#phread").mk_chapterLinks();
    $("#phread").mk_like();
  };
  if($("#login").length)
    $("#login").mk_loginForm();
  $("html").mkHelp();

  $(".uplinkb").each(function(){ $(this).setupUplink(); });
});
