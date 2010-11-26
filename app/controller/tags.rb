#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class TagsController < PalavrController
  map "/t"
  set_layout_except("layout" => [:all, :phread])
  
  helper :auth

  before(:create){
    login_required
  }

  # json output probably better
  def all
    Tag.all.map{|t| "#{t.tag} "}
  end

  def phread(action, id, tag)
    phread = Phread[id.to_i]
    tag = Tag.find_or_create(:tag => tag)
    case action
    when "remove"
      phread.remove_tag(tag)
    when "add"
      phread.add_tag(tag)
    end
    ''
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
