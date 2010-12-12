#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class ModController < PalavrController
  map "/mod"
  set_layout_except("layout" => [])

  helper :auth
  # before(:my, :like, :unlike){
  #   login_required
  # }

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
