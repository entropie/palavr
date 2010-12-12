#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "digest/md5"

module Palavr
  module Database::Tables

    class Phread < Table(:phread)
    end
    
    class User < Table(:user)

      one_to_many :posts
      one_to_many :threads
      one_to_many :privmsgs

      one_to_many :phreads, :key => :op_id
      
      many_to_many :phread_like, :class => Phread, :right_key => :phread_id, :left_key => :user_id

      
      Shema = proc{
        DB.create_table :user do
          primary_key :id

          int         :admin, :default => 0
          int         :mod, :default => 0

          foreign_key :mod_id
          
          varchar     :name

          varchar     :nick, :unique => true, :size => 120
          
          varchar     :email, :unique => true, :size => 255
          varchar     :passwd, :size => 32
        end
      }

      def phreads_sorted
        Phread.sort(phreads)
      end


      def my(limit = 10)
        query = "SELECT "+
          "phread.*, user.id as uid, user.email as email, "+
          "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
          "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
          "FROM phread "+
          "LEFT JOIN user ON phread.op_id = user.id "+          
          "INNER JOIN phreads_users "+
          "ON phreads_users.phread_id = phread.id "+
          "WHERE phread.op_id = #{self.id} "+
          "GROUP BY phread.id "+
          "ORDER BY count DESC "+
          "LIMIT #{limit}"
        res = Palavr::DB[query]
        res.map{|a| a.extend(Palavr::E)}
      end

      
      def liked(limit = 10)
        query = "SELECT "+
          "phread.*, user.id as uid, user.email as email, "+
          "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
          "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
          "FROM phread "+
          "LEFT JOIN user ON phread.op_id = user.id "+          
          "INNER JOIN phreads_users "+
          "ON phreads_users.phread_id = phread.id "+
          "AND phreads_users.user_id = #{self.id} "+
          "LIMIT #{limit}"          
        res = Palavr::DB[query]
        res.map{|a| a.extend(Palavr::E)}
      end
      
      def like?(pid = nil)
        query = "SELECT "+
          "phread.* FROM phread INNER JOIN phreads_users "+
          "ON phreads_users.phread_id = phread.id "+
          "AND phreads_users.user_id = #{self.id} "+
          "WHERE phread.id = #{pid}"
        res = Palavr::DB[query]
        not res.to_a.empty?
      end
      
      def like(obj)
        add_phread_like(obj) unless obj.liker.include?(self)
      end

      def unlike(obj)
        remove_phread_like(obj) if obj.liker.include?(self)# and obj.op != self
      end
      

      def authorized?
        p self
        p is_admin?
        p is_mod?
        is_admin? or is_mod?
      end
      
      def is_admin?
        not admin == 0
      end

      def is_mod?
        not mod == 0
      end
      
      def public_dir
        ud = Palavr::Opts[:data_dir] + "/user/#{id}/"
        FileUtils.mkdir_p(ud)
        ud
      end
      

      def pw1; passwd end
      def pw2; passwd end
      
      def self.pwcrypt(pw)
        Digest::MD5.
          hexdigest(pw||
                    (('a'..'z').to_a + ('A'..'Z').to_a).flatten.
                    sort_by{ rand }.last(8).join
                    )
      end


      def has_userpic?
        base = public_dir + "thumb_avatar.jpg"
        #thumb = public_dir + "thumb_avatar.jpg"        
        File.exists?(base) #and File.exists?(thumb)
      end

      def avatar(big = false)
        fname = "/data/user/#{id}/"+"#{big ? "" : "thumb_"}avatar.jpg"
        return "/img/uuser.gif" unless has_userpic?
        fname
      end

      def profile_img(big = false)
        fname = "/data/user/#{id}/"+"#{big ? "" : "thumb_"}profile.jpg"
        return "/img/uuser.gif" unless has_userpic?
        fname
      end

      
      def display_name
        ret = ''
        ret << (nick||name).to_s
        unless (nick.to_s.size + name.to_s.size) > 0
          ret << email.to_s.split("@").first + "@"
        end
        ret
      end
      
      def display_html
        ret = ''
        ret << '<em>' + nick + '</em>' if nick.to_s.size > 0
        ret << "<strong>#{name}</strong>"

        unless (name.to_s.size + name.to_s.size) > 0
          ret << "asdkj"
        end
        "<div class='namelink'>%s</div>" % ret
      end

      def profile_url
        "/u/#{id}"
      end
      
      def profile_link(opts = {})
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<span class='uplinkb'><a #{o} class='uplink' href='#{profile_url}'>#{display_name}</a></span>"
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

