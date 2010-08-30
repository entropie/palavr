#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class BoardController < PalavrController
  map :/
  set_layout("layout" => [:index]) {|path, wish| not request.xhr? }

  helper :auth
  before_all(){
    login_required
  }

  # def login; redirect(r(:auth, :login)) end
  # def logout; redirect(r(:auth, :logout)) end

  
  def index
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
