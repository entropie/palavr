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

      many_to_one :admin
      many_to_one :mod            

      one_to_many :phreads, :key => :op_id
      
      many_to_many :phread_like, :class => Phread, :right_key => :phread_id, :left_key => :user_id

      
      Shema = proc{
        DB.create_table :user do
          primary_key :id

          foreign_key :admin_user_id
          foreign_key :mod_user_id

          varchar     :name

          varchar     :nick, :unique => true, :size => 120
          
          varchar     :email, :unique => true, :size => 255
          varchar     :passwd, :size => 32
        end
      }

      def phreads_sorted
        Phread.sort(phreads)
      end


      def liked
        Phread.sort(phread_like)
      end
      
      def like(obj)
        add_phread_like(obj) unless obj.liker.include?(self)
      end

      def unlike(obj)
        remove_phread_like(obj) if obj.liker.include?(self)
      end
      
      
      def is_admin?
        not admin_user_id.nil?
      end

      def is_mod?
        not mod_user_id.nil?
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
        base = public_dir + "avatar.jpg"
        thumb = public_dir + "thumb_avatar.jpg"        
        File.exists?(base) and File.exists?(thumb)
      end

      def userpic(big = false)
        fname = "/data/user/#{id}/"+"#{big ? "" : "thumb_"}avatar.jpg"
        return "/img/uuser.gif" unless has_userpic?
        fname
      end

      def display_name
        ret = ''
        ret << (nick||name).to_s
        unless (name.to_s.size + name.to_s.size) > 0
          ret << email.split("@").first + "@"
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
      
      def profile_link(opts = {})
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='profile' href='/user/profile/#{id}'>#{display_name}</a>"
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

