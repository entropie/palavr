#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
#p Sequel::VERSION
module Palavr
  module Database::Tables

    class Phread < Table(:phread)
      many_to_one      :category
      many_to_one      :op, :class => User
      many_to_many     :phreads, :class => Phread, :left_key => :parent_id, :right_key => :phread_id

      
      Shema = proc{
        DB.create_table :phread do
          primary_key   :id

          foreign_key   :category_id
          foreign_key   :op_id

          datetime     :created_at
          datetime     :updated_at
          
          text          :title
          text          :body
        end
      }

      def before_create
        self.created_at = Time.now
      end

      
      def Phread.get(phread)
        if phread.scan(/[0-9]/).size == phread.size
          Phread[phread.to_i]
        else
          Phread.find(:title => CGI.unescape(phread))
        end
      end

      def from
        op
      end

      def parent
        Phread[PhreadsPhreads.find(:phread_id => id).parent_id]
      end

      def link(opts = {})
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='awesome small silver phreadlink' title='Story: #{title}' href='#{url}'>#{title}</a>"
      end
      
      def backlink
        category ? category.link : parent.link
      end
      
      def url
        "/s/#{id}/" + CGI.escape(title)
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
