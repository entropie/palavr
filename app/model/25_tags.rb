#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Palavr
  module Database::Tables

    class Tag < Table(:tag)
      many_to_many     :phreads, :class => Phread 
      
      
      Shema = proc{
        DB.create_table :tag do
          primary_key   :id

          varchar       :tag
        end
      }


      def phreads_sorted
        Phread.sort(phreads)
      end
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
