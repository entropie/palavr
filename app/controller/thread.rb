#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class Phread < PalavrController
  map "/s"
  set_layout("layout") # => [:index]) {|path, wish| not request.xhr? }

  helper :auth
  before_all(){
    login_required
  }


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
