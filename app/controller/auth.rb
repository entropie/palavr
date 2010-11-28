#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class AuthController < PalavrController

  set_layout("layout") # => [:index]) {|path, wish| not request.xhr? }
  
  map "/auth"
  
  def login

    @ruri = request.params["ruri"]

    unless request.post?
      @all_user = User.all[1..-1]
    else
      pp request
      @title = "Authentifizierung"
      username = request[:username].strip
      password = request[:password].strip

      p password, username
      p password.size
      p check_auth(username, User.pwcrypt(password))
      
      if check_auth(username, password)
        session[:logged_in] = true
        session[:username] = username
        session[:password] = User.pwcrypt(password)
        redirect @ruri
      else
        puts
        puts
        p username
        p User.pwcrypt(password)
        p User.find(:email => username)
        flash[:error] = "Unbekannter Benutzer oder falsches Passwort."
      end
      redirect AuthController.r(:login, :ruri => @ruri)
    end
  end
  
  def logout
    session[:username] = nil
    session[:password] = nil
    redirect BoardController.r(:/)
  end
  
end

#.split(";").map{#|str| str.split("=")}


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
