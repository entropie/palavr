
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
                    opacity: 90,
                    position: ["100px", "10%"]
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
      $(t).checkUserNameInput();
      $(this).unbind("click").slideUp();
      return false;
    });

    if($(t).find(".regform:visible").length){
      $(this).checkUserNameInput();
      $(t).checkAvailability();
    }
  };

   $.fn.setupUplink = function(){
     var app =  "<div class=\'inv app\'><ul>";
     var uid =$(this).find(".uplink").attr("href").split("/").reverse()[0];
     app += "<li class='pm'><a href='#/pm/" + uid + "'>Personal Message</a></li>";
     app += "<li class='stry'><a href='#/s/from/" +uid+ "'>All Stories</a></li>";
     app += "<li class='stry'><a href='#/s/from/" +uid+ "'>All Stories Lalal Keke Foo</a></li>";
     app += "<li class='stry'><a href='#/s/from/" +uid+ "'>All Stories</a></li>";
     app += "</ul>";
     app += '<img class="pic" src="/u/userpic/'+ uid + '" />';
     app += "</div>";
     $(this).hover(function(){
       $(this).append(app);
         // var avatarurl = '/data/user/' + uid + '/thumb_avatar.gif';
         // $.ajax({
         //   url:avatarurl,
         //   success: function(data){
         //     $(app).find('pic').attr("src", avatarurl);
         //     $(app).find('pic').removeClass("inv");

         //   },
         //   error: function(data){ $(app).find('opic').removeClass("inv"); }
         // });

       $(this).find(".app").delay(800).fadeIn();
     }, function(){
       $(this).find(".app").remove();
       $(this).removeClass("act");
     });
   };


   $.fn.checkUserNameInput = function() {
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
   };


  $.fn.checkAvailability = function() {
    $("#login .nick").append(spinner);
    $("#username").change(function(){ $(this).checkUserNameInput(); });
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

  $.fn.mk_ajax_upload = function() {
      var t = $(this);
      var upic = $("#editme .userpic");
      var apic = $("#user .avatar");
      var imb = $("img", upic);
      var amb = $("img", apic);


      if (t.hasClass("c_profile"))
      new AjaxUpload("profile_upload", {
        action: $(t).attr("action"),
        name: "image",
        onSubmit: function(file, extension){
          $(imb).slideUp("slow");
        },
        onComplete: function(file, response){
          $(imb).load(function() {
          });
          $(imb).attr("src", $(response).text());
          $(imb).slideDown();

        }
      });
      if (t.hasClass("c_avatar"))
      new AjaxUpload("avatar_upload", {
        action: $(t).attr("action"),
        name: "image",
        onSubmit: function(file, extension){
          $(amb).slideUp("slow");
        },
        onComplete: function(file, response){
          $(amb).load(function() {
          });
          $(amb).attr("src", $(response).text());
          $(amb).slideDown();

        }
      });
      return false;

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

  if($("#editme").length){
    $("#editme .profilechng").each(function() { $(this).mk_ajax_upload(); });
  };

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
