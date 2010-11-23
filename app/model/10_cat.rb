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
      
      def public_dir
        ud = Palavr::Opts[:data_dir] + "/category/#{id}/"
        FileUtils.mkdir_p(ud)
        ud
      end

      def pic?
        File.exist?(File.join(public_dir, "category.jpg"))
      end

      def pic
        if pic? then
          "#{Palavr::Opts[:www_data_dir]}/category/#{id}/category.jpg"
        else
          "/img/nopic.png"
        end
      end
      
      
      def url
        "/cat/#{id}/" + CGI.escape(title)
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
