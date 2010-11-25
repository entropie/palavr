#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class PhreadController < PalavrController
  map "/s"
  set_layout_except("layout" => [:phreads_for, :like, :unlike]) # => [:index]) {|path, wish| not request.xhr? }

  helper :auth
  before(:my, :like, :unlike){
    login_required
  }


  # gernerates a tree of all phreads and subphreads
  def phreadsub(mphread, o = 0)
    str = ''
    margin = o == 0 ? 0 : 20

    phreads = mphread.phreads_sorted

    # skip if there is nothing to do
    return '' unless phreads.size > 0
    
    str << "<div class=\"box\" style=\"margin-left:#{margin}px\">"

    # inline
    phreads.select{|mp| mp.after_parent_chap }.each do |phread|
      str << render_file("view/thread/_thread.haml", :phread => phread, :inline => true)
      str << phreadsub(phread, o+=1)
    end

    # standard
    phreads.reject{|mp| mp.after_parent_chap }.each do |phread|
      str << render_file("view/thread/_thread.haml", :phread => phread)
      str << phreadsub(phread, o+=1)
    end
    
    str << "</div>"    
    str
  end
  private :phreadsub
  

  def my(arg = nil)
    @topic, @phreads =
      case arg
      when 'liked'
        ["Stories I like", session_user.liked]
      else
        ["My Stories", session_user.phreads_sorted]
      end
  end

  
  def like(id)
    phread = Phread[id.to_i]
    session_user.like(phread)
    unless request.xhr?
      redirect phread.url
    else
      phread.star(session_user, true)
    end
  end
  
  def unlike(id)
    phread = Phread[id.to_i]
    session_user.unlike(phread)
    unless request.xhr?
      redirect phread.url
    else
      phread.star(session_user, true)
    end
  end
  
  def tree(id, phread = nil)
    redirect BoardController.r unless phread or id
    @phread = Phread[id.to_i]
  end
  

  def phreads_for(phreadid, para)
    phreadid = phreadid.to_i
    para = para.delete("para").to_i
    @phreads = Phread[phreadid].phreads_for_chapter(para)
  end
  
  
  # TODO: category images
  def index(id = nil, phread = nil)
    redirect BoardController.r unless phread or id
    @phread = Phread[id.to_i]
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
