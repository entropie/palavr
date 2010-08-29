#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class PalavrController < Ramaze::Controller
  engine :Haml

  set_layout_except 'layout' => [:login, :logout]
  set_layout        'simple_layout' => [:login, :logout]
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
