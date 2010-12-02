#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class BoardController < PalavrController
  map :/
  set_layout_except("layout" => [:help])
  
  helper :auth
  before(:create){
    login_required
  }

  def submit
  end

  def create
    redirect PhreadController.r(:create, request.params)
  end
  
  def index
    @categories = Category.all
  end

  def help
  end

  def logout
    redirect AuthController.r(:logout)
  end
  def login
    redirect AuthController.r(:login)
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
