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


  def submit
  end


  PthreadStruct = Struct.new(:title, :body, :category, :submit, :phreadid)
  def create
    if c=request.params["category"]
      @category = Category[c.to_i]
      @legend = "New Story to <em>#{@category.title}</em>"
    else
      @legend = "Thread"
    end

    @preview = {}
    if request.params["title"]
      @preview = PthreadStruct.new
      request.params.each_pair do |k,v|
        @preview.send("#{k}=", v)
      end
      pp @preview
    end
  end
  
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
