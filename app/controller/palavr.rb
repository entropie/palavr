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
  
  set_layout_except 'layout' # => [:login, :logout]
  #set_layout        'simple_layout' => [:login, :logout]


  def pgint(what, listproc)
    start = (request.params["page"] || 1).to_i
    hmany = 5
    #pp listproc.call(start, hmany).size
    #    listproc.call
    #[]
  end
  
  def self.ttip(what = nil)
    {
      :write_on   => "write on blabla",
      :write      => "bla",
      :tags       => "tags help",
      :tags_mod   => "tags help mod",
      :follow_ups => "follow ups help",
      :tree_link  => "tree",
      :create_acc => "Create an account. Its a matter of seconds!",
      :email      => "email add",
      :passwd     => "password",
      :rpasswd    => "repeat password",
      :phread_cr_title => "title",
      :phread_cr_body  => "body"
    }
  end
  
  def Tooltip(what)
    PalavrController::ttip[what]
  end

  def self.Tooltip(what)
    PalavrController::ttip[what]    
  end
  
  def lala
    "lala"
  end
  
  def Icon(which, clr = "orange", h = 12, w = 12, icons = 16)
    "<img width=\"#{w}\" height=\"#{h}\" class=\"icon\" src=\"/img/ics/#{which}_#{clr}_#{icons}.png\" />"
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
