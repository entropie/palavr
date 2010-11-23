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
        end
      }

      def self.sort(phreads)
        phreads.sort_by{|phread| phread.liker.size }.reverse
      end
      
      def phreads_sorted
        Phread.sort(phreads)
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
        [:title, :body].each do |e|
          raise MissingInput, "missing #{e}" if struc.send(e).to_s.strip.empty?
        end

        phread = Phread.create(:title => struc.title,
                               :body  => struc.body)
        phread.op = user
        phread.after_parent_chap = struc.p.to_i if struc.p and not struc.p.empty?

        phread.save
        
        if struc.phreadid and not struc.phreadid.empty?
          Phread.get(struc.phreadid).add_phread(phread)
        else
          category.add_phread(phread)
        end
        
        phread
      end

      def Phread.get_chapters(phread)
        ret, para, i = [], 0, 0

        phread.body.strip.each_line do |line|
          if line.strip.empty? then para += 1
          else
            ret << line.strip
            para = 0
            i+=1
          end
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

      def html_body
        ret = []
        chaps = chapters
        chaps.each do |chap, i|
          ret << "<div class='para' id='para#{i}'><ul>"

          str = if (fs=phreads_for_chapter(i).size) > 0
                  "<li class=\"moar\"><a class=\"awesome medium orange\">Follow Ups (#{fs})</a></li>"
                end || ""

          # skip last paragraph link
          unless (chaps.size-1)==i
            link = "<li ><a class='awesome medium silver' href='/create?phreadid=#{id};p=#{i}'>Write</a></li>"
            ret << "<div class='writemore'>#{link}#{str}</div>"
          end
          
          ret << "</ul><p>" << chap << "</p>"

          ret << "</div>"
        end
        ret.join
      end

      def phreads_for_chapter(chapter)
        Phread.sort(phreads.select{|phr| phr.after_parent_chap == chapter}) || []
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
        "<a #{o} class='awesome small silver phreadlink' title='Story: #{title}' href='#{url}#{anc}'>#{title}</a>"
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
      
      def url
        "/s/#{id}/" + CGI.escape(title.delete("..").strip)
      end

      def star(user)
        cls, title, img = 
          if liker.include?(user)
            [:star, :unlike, "starred-small"]
          else
            [:gstar, :like, "starred-small-g"]
          end
        link = "<a class='like_link' href=\"/s/#{title}/#{id}\">%s</a>"
        link % "<img id=\"phread_#{id}\" class=\"#{cls}\" src=\"/img/#{img}.png\" height=\"16\" width=\"16\" title=\"#{title}\" />"
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
