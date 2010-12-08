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

  PhreadsPerPage = 10
  
  def cat(catid, title = nil)
  end

  
  def index(catid, title = nil)
    page = (request.params["page"] || 1).to_i
    redirect BoardController.r unless catid
    @category = Category[catid.to_i]
    @threads  = @category.get_ordered_and_paginated(page, PhreadsPerPage)
  end
  
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
