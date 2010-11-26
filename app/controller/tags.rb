#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class TagsController < PalavrController
  map "/t"
  set_layout_except("layout" => [:all])
  
  helper :auth

  before(:create){
    login_required
  }

  # json output probably better
  def all
    Tag.all.map{|t| "#{t.tag} "}
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
