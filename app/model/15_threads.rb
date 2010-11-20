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

          datetime      :created_at
          datetime      :updated_at
          
          text          :title
          text          :body
        end
      }


      def self.create_from_struct(struc, user, category, org = nil)
        [:title, :body].each do |e|
          raise MissingInput, "missing #{e}" if struc.send(e).to_s.strip.empty?
        end
        phread = Phread.create(:title => struc.title,
                               :body  => struc.body)
        phread.op = user
        phread.save
        if struc.phreadid and not struc.phreadid.empty?
          Phread.get(struc.phreadid).add_phread(phread)
        else
          category.add_phread(phread)
        end
        
        phread
      end

      def html_body
        ret = []
        para,i = 0, 0
        body.each_line do |line|
          if line.strip.empty?
            para += 1
          else
            ret << "<div class='para' id='para#{i}'>" <<
              "<div class='writemore'><a class='awesome medium silver' href='#para#{i}'>Write</a></div><p>" <<
              line.strip << "</p></div>"
            para = 0
            i+=1
          end
        end
        ret.join
      end

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
      rescue
        nil
      end

      def link(opts = {})
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='awesome small silver phreadlink' title='Story: #{title}' href='#{url}'>#{title}</a>"
      end
      
      def backlink
        category ? category.link : parent.link
      end
      
      def url
        "/s/#{id}/" + CGI.escape(title.delete("..").strip)
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
