#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Palavr
  module Database::Tables

    class Phread < Table(:phread)
      many_to_one      :category
      many_to_one      :op, :class => User
      many_to_many     :phreads, :class => Phread, :left_key => :parent_id, :right_key => :phread_id
      many_to_many     :phread_like, :class => User, :left_key => :phread_id, :right_key => :user_id
      many_to_many     :tags
      
      
      Shema = proc{
        DB.create_table :phread do
          primary_key   :id

          foreign_key   :category_id
          foreign_key   :op_id

          datetime      :created_at
          datetime      :updated_at
          
          text          :title
          text          :body

          int           :after_parent_chap

          int           :readonly, :default => false
          
        end
      }

      def get_ordered_stream(f = true)
        query="SELECT "+
          "phread.*, user.id as uid, user.email as email, "+
          "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
          "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
          "FROM phread "+
          "LEFT JOIN user ON phread.op_id = user.id "+
          "INNER JOIN phreads_phreads as np ON np.phread_id = phread.id "+
          "AND np.parent_id = #{self.id} and phread.after_parent_chap IS " + (f ? "" : ' NOT ') + "NULL " + 
          "ORDER BY COUNT DESC "
        Palavr::DB[query]
      end


      def get_ordered
        query="SELECT "+
          "phread.*, user.id as uid, user.email as email, "+
          "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
          "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
          "FROM phread "+
          "LEFT JOIN user ON phread.op_id = user.id "+
          "INNER JOIN phreads_phreads as np ON np.phread_id = phread.id "+
          "AND np.parent_id = #{self.id} "+
          "ORDER BY COUNT DESC, phread.created_at DESC "
        Palavr::DB[query]
      end

      def phreads_for_chapter(chapter)

        query="SELECT "+
          "phread.*, user.id as uid, user.email as email, "+
          "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
          "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
          "FROM phread "+
          "LEFT JOIN user ON phread.op_id = user.id "+
          "INNER JOIN phreads_phreads as np ON np.phread_id = phread.id "+
          "WHERE phread.after_parent_chap = #{chapter} "+
          "AND np.parent_id = #{self.id} "+
          "ORDER BY COUNT DESC "
        Palavr::DB[query]
      end

      
      def self.sort(phreads, s = 0, max = 5)
        phreads.sort_by{|phread| phread.liker.size }.reverse
      end
      
      def phreads_sorted(s = 0, max = 5)
        get_ordered
      end
      
      def liker
        phread_like
      end

      def category
        res = super
        return parent.category if res.nil?
        res
      end

      def self.create_from_struct(struc, user, category, org = nil)
        [:body].each do |e|
          raise MissingInput, "missing #{e}" if struc.send(e).to_s.strip.empty?
        end

        phread = Phread.create(:title => struc.title,
                               :body  => struc.body)

        raise MissingInput, "no user" unless user
        phread.op = user
        phread.after_parent_chap = struc.p.to_i if struc.p and not struc.p.empty?

        phread.save
        
        if struc.phreadid and not struc.phreadid.empty?
          Phread.get(struc.phreadid).add_phread(phread)
        else
          category.add_phread(phread)
        end
        #user.like(phread)
        phread
      end

      def Phread.get_chapters(phread)
        ret = []
        phread.body.chapters do |chapter, index|
          ret << chapter
        end
        ret
      end

      def chapters(index = nil)
        i, ret = -1, Phread.get_chapters(self)

        ret.each do |chapter|
          yield chapter.strip, i+=1
        end if block_given?

        ret.map!{ |chap| [chap, ret.index(chap)] }
        if index
          ret.select{ |r,i| i == index}.first
        else
          ret
        end
      end


      def title
        t = super.to_s.strip
        t.empty? ? body[0..60] : t
      end
      
      def html_title
        title
      end
      
      def html_body
        ret = []
        chaps = chapters
        chaps.each do |chap, i|
          ret << "<div class='para' id='para#{i}'><ul>"

          str = if (fs=phreads_for_chapter(i).to_a.size) > 0
                  "<li id=\"follow_ups\" class=\"moar\"><a class=\"awesome medium orange\">Follow Ups (#{fs})</a></li>"
                end || ""

          # skip last paragraph link
          unless (chaps.size-1)==i or readonly?
            link = "<li><a title=\"#{PalavrController::Tooltip(:write)}\" class='ttip awesome medium silver' href='/create?phreadid=#{id};p=#{i}'>Write</a></li>"
            ret << "<div class='writemore'>#{link}#{str}</div>"
          end
          
          ret << "</ul><p>" << chap << "</p>"

          ret << "</div>"
        end
        ret.join
      end

      def email(phread)
      end
      
      def readonly?
        readonly == 1
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

      def link(with_anchor = true, opts = {})
        phread = opts[:phread]
        anc = with_anchor ? ("#para#{phread.after_parent_chap}" || "#phread") : "" rescue "#phread"
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='awesome small silver blink' title='Story: #{title}' href='#{url}#{anc}'>#{title}</a>"
      end
      
      def backlink(with_anchor = true)
        link = parent.link(true, :phread => self)
        link
      rescue
        ''
      end

      def cat_backlink(with_anchor = true)
        category.link
      end

      def url_title
        CGI.escape(title.delete("..").strip)
      end
      
      def url
        "/s/#{id}/" + url_title
      end
      def Phread.url(h)
        "/s/#{h[:id]}/" + url_title
      end

      def star(user, wlink = true, x = 16, y = 16)
        liked = user.like?(self.id)
        cls, title, img = 
          if liked
            [:star, :unlike, "starred-small"]
          else
            [:gstar, :like, "starred-small-g"]
          end
        link = "<a class='like_link' href=\"/s/like/#{title}/#{id}\">%s</a>"
        title = unless liked then "Like this Story" else "Don't like this Story anymore" end
        unless wlink
          link = "%s"
          title = if liked then "You like this Story" else "You don't like this Story" end
        end
        
        link % "<img id=\"phread_#{id}\" class=\"#{cls} ttip\" src=\"/img/#{img}.png\" height=\"#{x}\" width=\"#{y}\" title=\"#{title}\" />"
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
