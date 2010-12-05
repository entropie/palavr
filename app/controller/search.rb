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
    result = {}
    query = params["s"].to_s.strip
    result[:phreads] = Phread.filter(:title.like("%#{query}%") | :body.like("%#{query}%")).limit(10)
    result[:user]    = User.filter(:name.like("%#{query}%") | :nick.like("%#{query}%"))
    result[:fromuser]= []
    User.filter(:name.like("%#{query}%") | :nick.like("%#{query}%")).each do |r|
      r.phreads_sorted.each do |phread|
        result[:fromuser] << phread
      end
    end

    tags = Tag.find(:tag => query)
    result[:fromtags] = tags.phreads_sorted.to_a if tags
    result[:fromtags] ||= []
    result
  end
  
  def index
  end

  def _all
    @query = request.params["s"].to_s.strip
    @result = SearchController.search(request.params)
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
