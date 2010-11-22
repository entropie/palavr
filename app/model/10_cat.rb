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

      def phreads_sorted
        Phread.sort(phreads)
      end

      def self.get_category(cat)
        if cat.scan(/[0-9]/).size == cat.size
          Category[cat.to_i]
        else
          Category.find(:title => CGI.unescape(cat))
        end
      end

      def link(opts = {})
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='awesome small silver catlink' title='Category: #{title}' href='#{url}'>#{title}</a>"
      end
      
      
      def self.mk_url(cat)
        if cat.scan(/[0-9]/).size == cat.size
          "/cat/" + cat
        else
          "/cat/" + CGI.escape(cat)
        end
      end
      
      def url
        Category.mk_url(title)
      end

      def self.by_name(cat)
        Category.find(:title => CGI.unescape(cat))
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
