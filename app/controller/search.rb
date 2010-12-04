#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class SearchController < PalavrController
  map "/search"
  set_layout_except("layout" => [:_all])
  
  # helper :auth
  # before(:me){
  #   login_required
  # }


  def self.search(params)
    result = Hash.new{|h,k| h[k] = []}
    query = params["s"].to_s.strip
    puts query
    phreads = Phread.filter(:title.like("%#{query}%") | :body.like("%#{query}%")).limit(10)
    #sleep 3

  end
  
  def index
  end

  def _all
    @result = {}
    s = SearchController.search(request.params)
    pp s.count
    @result[:phreads] = s
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
