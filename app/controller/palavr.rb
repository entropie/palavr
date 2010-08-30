#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class PalavrController < Ramaze::Controller
  engine :Haml
  helper :auth
  
  include Palavr::Database::Tables
  
  set_layout_except 'layout' # => [:login, :logout]
  #set_layout        'simple_layout' => [:login, :logout]

  
  # FIXME: ~/Source/ramaze/lib/ramaze/helper/auth.rb needs to be edtited to make that auth thingy work.
  def login_required
    flash[:error] = 'login required to view that page' unless logged_in?
    super
  end
  
  def session_user
    User.find(:email => session[:username]) if session
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
    if usr = User[:email => email, :passwd => pw]
      true
    else
      flash[:error] = 'Falscher Benutzername und/oder Passwort.'      
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
