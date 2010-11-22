#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class AuthController < PalavrController

  set_layout("layout") # => [:index]) {|path, wish| not request.xhr? }
  
  map "/auth"
  
  def login

    @backto = request.params["backto"]
    unless request.post?
      @all_user = User.all[1..-1]
    else
      @title = "Authentifizierung"
      username = request[:username].strip
      password = request[:password].strip
      if check_auth(username, password)
        session[:logged_in] = true
        session[:username] = username
        session[:password] = User.pwcrypt(password)
        redirect @backto
      else
        flash[:error] = "Unbekannter Benutzer oder falsches Passwort."
      end
      redirect AuthController.r(:login, :backto => @backto)
    end
  end
  
  def logout
    session[:username] = nil
    session[:password] = nil
    redirect BoardController.r
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
