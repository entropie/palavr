#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class PhreadController < PalavrController
  map "/s"
  set_layout_except("layout" => [:phreads_for]) # => [:index]) {|path, wish| not request.xhr? }

  helper :auth
  before_all(){
    login_required
  }


  def phreads_for(phreadid, para)
    phreadid = phreadid.to_i
    para = para.delete("para").to_i
    @phreads = Phread[phreadid].phreads_for_chapter(para)
  end
  
  
  # TODO: category images
  def index(id, phread = nil)
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
