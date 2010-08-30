#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Enumerable
  # stolen from rake
  def group_by
    inject([]) do |groups, element|
      value = yield(element)
      if (last_group = groups.last) && last_group.first == value
        last_group.last << element
      else
        groups << [value, [element]]
      end
      groups
    end
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
