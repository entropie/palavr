#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MissingInput < Exception
end


class PalavrController < Ramaze::Controller
  engine :Haml
  helper :auth
  
  include Palavr::Database::Tables
  
  layout(:layout) { !request.xhr? }
  #set_layout        'simple_layout' => [:login, :logout]

  def star(phread, suser, link = true, x = 12, y = 12)
    Phread[phread[:id]].star(suser, link, x, y)
  end

  def profile_link(uid, email, rest = nil)
    if uid.kind_of?(Hash)
      return User[uid[:uid]].profile_link
    end
    User[uid].profile_link
  end
  
  def self.ttip(what = nil)
    {
      :write_on   => "write on blabla",
      :write      => "bla",
      :tags       => "tags help",
      :tags_mod   => "tags help mod",
      :follow_ups => "follow ups help",
      :tree_link   => "Show Tree from this entry",
      :stream_link => "Generate story by top-rated Entries ",      
      :create_acc => "Create an account. Its a matter of seconds!",
      :email      => "email add",
      :passwd     => "password",
      :rpasswd    => "repeat password",
      :phread_cr_title => "title",
      :phread_cr_body  => "body",
      :fontsel_block_desc   => "Block Font",
      :fontsel_default_desc => "Overall Font"
    }
  end
  
  def Tooltip(what)
    PalavrController::ttip[what]
  end

  def self.Tooltip(what)
    PalavrController::ttip[what]    
  end
  
  def Icon(which, clr = "orange", h = 12, w = 12, icons = 16, opt = {})
    puts
    ostr = ' '
    if not opt.empty?
      opt.each_pair { |k, v|
        case k
        when "data-hoverimg-color"
          ostr << " data-HIMG='%s' " % "/img/ics/#{which}_#{v}_#{icons}.png"
        end
      }
    end
    "<img#{ostr}width=\"#{w}\" height=\"#{h}\" class=\"icon\" src=\"/img/ics/#{which}_#{clr}_#{icons}.png\" />"
  end

  def TIcon(which, clr = "dark", h = 12, w = 12, icons = 16)
    "<img width=\"#{w}\" height=\"#{h}\" class=\"ticon\" src=\"/img/tokenics/#{clr}/#{which.to_s.capitalize}.png\" />"
  end

  
  def login_required
    unless logged_in?
      flash[:error] = 'login required to view that page'
      call(AuthController.r(:login, :ruri => request.request_uri))
    end
  end

  def session_user
    if session and session[:username].to_s.strip.size > 0
      User.find(:email => session[:username]) or User.find(:nick => session[:username])
    end
  end
  
  def logged_in?
    check_auth(session[:username].to_s, session[:password].to_s)
  end

  def check_auth(email, pass)
    return false if (not email or email.empty?) and (not pass or pass.empty?)
    if pass.size == 32
      pw = pass
    else
      pw = User.pwcrypt(pass)
    end
    if User[:email => email, :passwd => pw]
      true
    elsif User[:nick => email, :passwd => pw]
      true
    else
      false
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
