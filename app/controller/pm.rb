#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class PMController < PalavrController
  map "/pm"
  layout(:layout) { !request.xhr? }
  
  helper :auth

  before(:create){
    login_required
  }

  def to(id)
    "lalal"
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
