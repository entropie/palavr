#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "digest/md5"

module Palavr
  module Database::Tables

    class User < Table(:user)

      one_to_many :posts
      one_to_many :threads
      one_to_many :privmsgs
      one_to_many :shouts

      #one_to_many :jobs, :class => :Job, :key => :orderer_id
      
      many_to_one :admin
      many_to_one :mod            

      many_to_many :phread_like, :class => :Phread, :right_key => :phread_id, :left_key => :user_id

      
      Shema = proc{
        DB.create_table :user do
          primary_key :id

          foreign_key :admin_user_id
          foreign_key :mod_user_id
          
          varchar     :email, :unique => true, :size => 255
          varchar     :passwd, :size => 32
        end
      }

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
      
      def profile_link(opts = {})
        name = email
        o = opts.map{|a,b| "#{a}='#{b}'"}.join(" ")
        "<a #{o} class='profile' title='#{User[id].email}s Profil' href='/user/profile/#{id}'>#{name || id}</a>"
      end

      def name_link(xhr = true, img = true, w = 14, h = 14)
        add = xhr ? " alink" : ''
        admin_add = is_admin? ? " <img src='/img/mics/star_full.png' width='#{w}' height='#{h}' title='Admin' />" : ""
        ia = "<img src='#{userpic}' width='#{w}' height='#{h}' alt='Benutzerbild' /> %s" % [name]
        "<a class='name_link#{add}' href='/user/profile/%i' title='#{name}'>%s</a>#{admin_add}" % [id, (img ? ia : name)]
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

