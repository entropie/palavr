(function($) {
  $.fn.tagit = function(options) {

    var el = this;

    const BACKSPACE = 8;
    const ENTER     = 13;
    const SPACE     = 32;
    const COMMA     = 44;

    // add the tagit CSS class.
    el.addClass("tagit");

    // create the input field.
    var html_input_field = "<li class=\"tagit-new\"><input class=\"tagit-input\" type=\"text\" /></li>\n";
    el.html (html_input_field);

    tag_input = el.children(".tagit-new").children(".tagit-input");

    // Add default tags for the input field
    if (options.startingTags != null){
      $.each(options.startingTags, function(key, tag){
        create_choice(tag);
      });
    }

    $(this).click(function(e){
      if (e.target.tagName == 'A') {
        $(e.target).parent().remove();
      } else {
        tag_input.focus();
      }
    });

    tag_input.keypress(function(event){
      if (event.which == BACKSPACE) {
        if (tag_input.val() == "") {
	  // When backspace is pressed, the last tag is deleted.
	  $(el).children(".tagit-choice:last").remove();
        }
      } else if (event.which == COMMA || event.which == SPACE || event.which == ENTER) {
        event.preventDefault();

        var typed = tag_input.val();
        typed = typed.replace(/,+$/,"");
        typed = typed.trim();

        if (typed != "") {
	  if (is_new (typed)) {
	    create_choice (typed);
	  }
	  // Cleaning the input.
	  tag_input.val("");
        }
      }
    });

    tag_input.autocomplete({
      source: options.availableTags,
      select: function(event,ui){
        if (is_new (ui.item.value)) {
          create_choice (ui.item.value);
        }
        // Cleaning the input.
        tag_input.val("");

        // Preventing the tag input to be update with the chosen value.
        return false;
      }
    });

    function is_new (value){
      var is_new = true;
      var n;
      this.tag_input.parents("ul").children(".tagit-choice").each(function(i){
        n = $(this).children("input").val();
	if (value == n) {
	  is_new = false;
	}
      });
      return is_new;
    }

    function create_choice (value){
      var el = "";
      el  = "<li class=\"tagit-choice\">\n";
      el += value + "\n";
      el += "<a class=\"close\">x</a>\n";
      el += "<input type=\"hidden\" style=\"display:none;\" value=\""+value+"\" name=\"item[tags][]\">\n";
      el += "</li>\n";
      var li_search_tags = this.tag_input.parent();
      $(el).insertBefore (li_search_tags);
      this.tag_input.val("");
    }
  };

  String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g,"");
  };

})(jQuery);
