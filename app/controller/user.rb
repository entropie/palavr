#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class UserController < PalavrController
  map "/u"
  set_layout_except("layout" => [:help, :upload, :userpic])
  
  helper :auth
  before(:me){
    login_required
  }

  def userpic(id)
    usr = User[id.to_i]
    redirect usr.avatar
  end
  
  def index(id_or_name, rest = nil)
    @user = User[id_or_name.to_i] || User.find(:nick => id_or_name)
  end


  # FIXME: filesize and dimension handling; also fix js for upload
  def upload(what)
    imgr = request.params["image"]

    tfile = imgr[:tempfile]
    filename = ''
    case what
    when "avatar"
      filename = 'thumb_avatar'
    when "profile"
      filename = 'profile'
    end

    path = "#{filename}.jpg"
    FileUtils.cp(tfile.path, File.join(session_user.public_dir, path))

    r="%url /data/user/#{session_user.id}/#{path}?rand=#{rand(1000000)+10000}"
    return r
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
