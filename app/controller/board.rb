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

  PthreadStruct = Struct.new(:title, :body, :category, :submit, :phreadid, :preview, :phread, :p)

  def create
    if pr=request.params["phreadid"] and not pr.empty?
      @parent_phread = Phread[pr.to_i]
      @category = @parent_phread.category
      @legend = "Thread"
      @form_append = {:phreadid => @parent_phread.id}      
    elsif c=request.params["category"]
      @category = Category[c.to_i]
      @legend = "New Story to <em>#{@category.title}</em>"
      @form_append = {:category => @category.id}
      # TODO: values for phread
    end

    @form_append.merge!(:p => request.params["p"]) if request.params["p"]

    @preview = {}
    if request.params["title"]
      @preview = PthreadStruct.new
      # copy values to PthreadStruct
      request.params.each_pair do |k,v|
        @preview.send("#{k}=", v)
      end
    end

    # create phread
    if @preview.kind_of?(Struct) and @preview.submit and not @preview.submit.empty?
      begin
        phread = Phread.create_from_struct(@preview, session_user, @category)
        redirect phread.url
      rescue MissingInput => e
        flash[:error] = e
      end
    end

  end
  
  # TODO: category images
  def index
    @categories = Category.all
  end

  def cat(catid, title = nil)
    call(:index) unless catid
    puts
    p catid
    @category = Category[catid.to_i]
    @threads = @category.phreads_sorted
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
