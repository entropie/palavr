#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Palavr
  module Database::Tables

    class Category < Table(:cat)

      one_to_many     :phreads
      many_to_many    :mods, :class => User


      Shema = proc{
        DB.create_table :cat do
          primary_key   :id
          text          :title
          text          :description
        end
      }

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
