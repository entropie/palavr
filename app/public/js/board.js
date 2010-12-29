
function debug(msg) {
  //$('#debug').append("<p>" + msg + "</p>");
  if (typeof(console) != 'undefined' && typeof(console.log) == 'function')
    console.log(msg);
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
     var uid =$(this).find(".uplink").attr("href").split("/").reverse()[1];
     app += "<li class='pm'><a href='/pm/to/" + uid + "'>Personal Message</a></li>";
     app += "<li class='stry'><a href='/s/by/" +uid+ "'>All Stories from user</a></li>";
     app += "<li class='strylk'><a href='/s/liked/" +uid+ "'>Stories this user like </a></li>";
     app += "</ul>";
     app += '<img class="pic" src="/u/userpic/'+ uid + '" />';
     app += "</div>";
     $(this).hover(function(){
       $(this).append(app);
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


   // TODO: make tooltip for star/unstar working
  $.fn.mk_like = function() {
    $(this).each(function(){
      var p = $(this);
      var ll = $(this).find(".like_link");
      var url = ll.attr("href");
      ll.unbind("click");
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
    });
  };

  $.fn.mkHelp = function(what) {
    $(".ttip", what).tooltip({
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

   $.fn.setupSearch = function() {
     var close_result = function(){
       $("#search_result").animate({
         height: "0px",
         width: "0px",
         opacity: 0.0
         }, 1000,function() {
           $("#search_result").remove();
       });
       $(this).remove();
     };

     $("form", this).submit(function(){
       $("#search_result").remove();
       $.ajax({
         url: $(this).attr("action"),
         cache: false,
         data: {s: $(this).find(".searchthingy").attr("value")},
         beforeSend: function(){
           $("#ssearch").append(spinner);
         },
         success: function(data){
           $("#ssearch .spinner").fadeOut(function(){$(this).remove();});
           $("#ssearch").append(data);
           $("#search_result .uplinkb").each(function(){ $(this).setupUplink(); });
           $("#ssearch .tabs").tabs({ fx: {opacity: 'toggle' }});
           $("#search_result").slideDown(function(){
             var html = '<img class="inv" src="/img/x.png" />';
             $(".close", this).html(html);
             $(".close img", this).fadeIn();

             $(".close img", this).click(close_result);
             //$("#search_result").slideUp(function(){$(this).remove();});
           });
         },
         error: function(data){  }
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
        $(".moar", p).find("a").unbind("click");
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


   var stream_append = function(){
     if(!$("#lmore").length) return false;
     $("#lmore").parent().append(spinner);
     $("#lmore").text("Loading...");
     $.ajax({
       type: "GET",
       url: $("#lmore").attr("href"),
       success: function(data){
         $("#lmore").parent().slideUp(function(){ $(this).remove(); });
         $("#stream").append(data);
         $("#stream").find(".phread").mk_chapterLinks();
         $("#stream").find(".phread").mk_like();
         $("#stream .icon").setup_icon_over();
         $("html").mkHelp("#stream");
         $("#lmore").setup_load_more();
       }
     });
   };

   $.fn.setup_load_on_scroll = function(){
     $(window).scroll(function(){
        if  ($(window).scrollTop() >= $(document).height() - $(window).height() - 100){
          //setTimeout("stream_append.call()", 2000);
          stream_append.call();
        };
     });
   };

   $.fn.setup_load_more = function() {
     $(this).parent().click(function(){
       stream_append.call();
       return false;
     });
   };

   $.fn.setup_icon_over = function() {
     $(this).each(function(){
       $(this).unbind();
       var hvimg = $(this).attr("data-himg");
                    debug(hvimg);
       if(hvimg){
         $(this).hover(function(){
           $(this).attr("data-oimg", $(this).attr("src"));
           $(this).attr("src", hvimg);
         }, function(){
           $(this).attr("src", $(this).attr("data-oimg"));
         });
       }

     });
   };

  $.fn.setupSidebar = function(what) {
    $(this).each(function(){
      $(this).find(".box h3").click(function(){
        $(this).parent().find("ul, >div").slideToggle();
        $(this).parent().find("ul, >div").parent().toggleClass("active");
      });

    });
  };
  $.fn.setupFontSel = function() {
    $("#fontsel .contents select").change(function(){
      var what = $(this).attr("name");
      var which = $(this).attr("value");
      if(which == "") return false;
      $("head .dynfont_" + what).attr("href", "/css/select/" + what + "/" + which);
    });
    // $("#fontsel .selecter").click(function(){
    //   $("#fontsel .contents").slideToggle();
    // });
  };

})(jQuery);

$(document).ready(function () {
  // $(window).bind('popstate', function() {
  // });

  $("html").setupFontSel();

  $("#ssearch").setupSearch();

  $("#helplink").toggleHelp();

  if($("#editme").length){
    $("#editme .profilechng").each(function() { $(this).mk_ajax_upload(); });
  };

  if($(".phread").length){
    if($(".tagline").length)
      $(".tagline").mk_tags();
    $(".phread").mk_chapterLinks();
    $(".phread").mk_like();
  };
  if($("#login").length)
    $("#login").mk_loginForm();
  $("html").mkHelp($("#wrap"));

  if($("#error").length)
    $("#error").delay(3000).slideUp("slow");

  $(".uplinkb").each(function(){ $(this).setupUplink(); });

 // $(".paginate").find("a").slide_click();
  if($("#stream").length){
    $("#lmore").setup_load_more();
    $("html").setup_load_on_scroll();
  }

  if($("#sidebar").length){
    $("#sidebar").setupSidebar();
  }
  $(".icon").setup_icon_over();

});
