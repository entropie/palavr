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

      def get_ordered
        query="SELECT "+
          "phread.*, user.id as uid, user.email as email, "+
          "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
          "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
          "FROM phread "+
          "LEFT JOIN cat ON phread.category_id = cat.id "+
          "LEFT JOIN user ON phread.op_id = user.id "+    
          "WHERE cat.id = #{id} "+
          "ORDER BY count DESC, phread.created_at DESC "
        Palavr::DB[query]
      end
      
      def get_ordered_and_paginate(page, off)
        ret = []
        paginated = get_ordered.paginate(page, off)

        res = paginated.to_a.map!{|a| a.extend(Palavr::E)}
        res
        [res, paginated]
      end
      
      
      def phreads_sorted(s, max)
        Phread.sort(phreads, s, max)
      end

      def self.get_category(cat)
        if cat.scan(/[0-9]/).size == cat.size
          Category[cat.to_i]
        else
          Category.find(:title => CGI.unescape(cat))
        end
      end

      def html_title
        title
      end

      def link(opts = {})
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='awesome small silver blink' title='Category: #{title}' href='#{url}'>#{title}</a>"
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
        if pic?
          "#{Palavr::Opts[:www_data_dir]}/category/#{id}/category.jpg"
        else
          "/img/nopic.png"
        end
      end
      
      
      def url
        "/c/#{id}/" + CGI.escape(title)
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
