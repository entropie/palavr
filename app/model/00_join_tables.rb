#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Palavr
  module Database::Tables


    # cat <-> mods
    class CategoriesUsers < Table(:categories_users)

      Shema = proc{
        DB.create_table :categories_users do
          foreign_key   :mod_id
          foreign_key   :category_id
        end
      }

    end
    # cat <-> mods
    class PhreadsPhreads < Table(:phreads_phreads)

      Shema = proc{
        DB.create_table :phreads_phreads do
          foreign_key   :parent_id
          foreign_key   :phread_id
        end
      }

    end

    # # cat <-> threads
    # class CategoriesPhreads < Table(:categories_phreads)

    #   Shema = proc{
    #     DB.create_table :categories_phreads do
    #       foreign_key   :phread_id
    #       foreign_key   :category_id
    #     end
    #   }

    # end
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
