#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
    
class CategoryController < PalavrController
  map "/c"
  #set_layout_except("layout" => [])
  
  helper :auth
  before(:create){
    login_required
  }
  def choose_cat
    @categories = Category.all
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
