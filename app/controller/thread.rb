#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class PhreadController < PalavrController
  map "/s"
  
  layout(:layout) { !request.xhr? } 
  helper :auth
  before(:my, :like, :unlike){
    login_required
  }


  MaxPhreadsPerPage = 5
  
  # gernerates a tree of all phreads and subphreads
  def phreadsub(mphread, o = 0)
    str = ''
    margin = o == 0 ? 0 : 20

    phreads = mphread.phreads_sorted #.to_a.map{|a| a.extend(Palavr::E)}
    # skip if there is nothing to do
    return '' unless phreads.count > 0
    
    str << "<div class=\"box\" style=\"margin-left:#{margin}px\">"


    unless o > 10
      phreadarr = phreads.to_a
      # inline
      phreadarr.select{|mp| mp[:after_parent_chap] }.each do |phread|
        pphread = phread.extend(Palavr::E)      
        str << render_file("view/thread/_thread.haml", :phread => pphread, :inline => true)
        str << phreadsub(Phread[phread[:id]], o+=1)
      end

      # standard
      phreadarr.reject{|mp| mp[:after_parent_chap] }.each do |phread|
        pphread = phread.extend(Palavr::E)
        str << render_file("view/thread/_thread.haml", :phread => pphread )
        str << phreadsub( Phread[phread[:id]], o+=1)
      end
    else
      # TODO:
      str << "<a class='loadmore' href='/s/tree/#{mphread.id}'>... More follow ups. Click to load</a>"
    end
    
    str << "</div>"
    str
  end
  private :phreadsub
  
  PthreadStruct = Struct.new(:title, :body, :category, :submit, :phreadid, :preview, :phread, :p)


  def create
    if request.params.empty?
      redirect CategoryController.r(:choose_cat)
    end
    
    # variables
    if pr=request.params["phreadid"] and not pr.empty?
      @parent_phread = Phread[pr.to_i]
      @category = @parent_phread.category
      @legend = "Thread"
      @form_append = {:phreadid => @parent_phread.id}      
    elsif c=request.params["category"]
      @category = Category[c.to_i]
      @legend = "New Story to <em>#{@category.title}</em>"
      @form_append = {:category => @category.id}
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


  def get_stream(phread, off = 0)
    ret = []
    if off >= MaxPhreadsPerPage
      return ["<div class='morebox'><a id='lmore' href='/s/more/#{phread.id}'>Load More</a></div>"]
    end
    
    ret << render_file("view/s/index.haml", :phread => phread, :stream => true)
    begin
      phreads = [phread.get_ordered_stream.first, phread.get_ordered_stream(false).first].flatten
      id = phreads.compact.sort_by{|pr| (pr[:countchilds])+(pr[:count]+1)**2}.reverse.first[:id]
      ret << get_stream(Phread[id], off+=1)
    rescue
      ''
    end
    ret
  end

  def stream(pid, rest = nil)
    @phread = Phread[pid.to_i]
    @stories = get_stream(@phread)
  end

  def more(pid)
    @phread = Phread[pid.to_i]
    @stories = get_stream(@phread)
  end
  
  def by(uid)
    @user = User[uid.to_i]
    @phreads = @user.my
  end

  def liked(uid)
    @user = User[uid.to_i]
    @phreads = @user.liked
  end
  
  
  def my(arg = nil)
    @topic, @phreads =
      case arg
      when 'liked'
        ["Stories I like",
         session_user.liked
        ]
      else
        ["My Stories",
         session_user.my]
      end
  end

  
  def like(what, id)
    raise "not allowed" unless ["like", "unlike"].include?(what)
    phread = Phread[id.to_i]
    session_user.send(what.to_sym, phread)
    unless request.xhr?
      redirect phread.url
    else
      phread.star(session_user)
    end
  end
  
  
  def tree(id, phread = nil)
    redirect BoardController.r unless phread or id
    @phread = Phread[id.to_i]
  end
  

  def phreads_for(phreadid, para)
    phreadid = phreadid.to_i
    para = para.delete("para").to_i
    @phreads = Phread[phreadid].phreads_for_chapter(para).to_a.map{|a| a.extend(Palavr::E)}
  end
  
  
  # TODO: category images
  def index(id = nil, phread = nil)
    redirect BoardController.r unless phread or id
    @phread = Phread[id.to_i]
    @childs = @phread.get_ordered.to_a.map{|a| a.extend(Palavr::E)}
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
