#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class BoardController < PalavrController
  map :/
  set_layout("layout") # => [:index]) {|path, wish| not request.xhr? }

  helper :auth
  before_all(){
    login_required
  }


  # TODO: category images
  def index(cat = nil)
    if cat and cat.scan(/[0-9]/).size == cat.size
      call(r(:cat, cat))
    else
      @categories = Category.all
    end
  end

  def cat(cat)
    @category = Category.get_category(cat)
    @threads = @category.phreads
  end
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
