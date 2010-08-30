#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
#p Sequel::VERSION
module Palavr
  module Database::Tables

    class Phread < Table(:thread)

      many_to_many     :categories
      many_to_one      :op, :class => User

      
      Shema = proc{
        DB.create_table :thread do
          primary_key   :id

          foreign_key   :category_id
          foreign_key   :op_id
          
          text          :title
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
