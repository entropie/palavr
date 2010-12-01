#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class HelpController < PalavrController
  map "/help"
  set_layout_except("layout" => [:index, :write_on, :write_more])

  helper :auth

  def index
  end
  
  def write_on
    "Use this to make a follow up of the current story. The natural history of each story, and the parts of it, is made by user contributions. Thats You! "
  end

  def write_more
    "You like this way to finish that Story? You dont need to Read more and just want to make a Follow up now? Press!"
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
