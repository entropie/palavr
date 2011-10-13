#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class AuthController < PalavrController

  layout(:layout) { !request.xhr? }

  map "/auth"

  def check_username
    un = request.params["username"].to_s.strip
    return "1" if un.empty?
    if User.find(:nick => un)
      "0"
    else
      "1"
    end
  end
  
  def login
    redirect BoardController.r if session_user
    @title = "Authentication"
    @ruri = request.params["ruri"]
    if @ruri =~ /^http/
      @ruri.gsub!(/https?:\/\//, '')
      @ruri = @ruri.split("/")[1..-1].join("/")
      @ruri = "/" if @ruri.empty?
    end

    
    unless request.post?
      @all_user = User.all[1..-1]
    else
      @title = "Authentifizierung"
      @username = request[:username].strip
      @password = request[:password].strip
      @rpw      = request[:rpw].to_s.strip

      ut = @username.include?("@") ? :email : :nick
      
      if check_auth(@username, @password)
        session[:logged_in] = true
        session[:username] = @username
        session[:password] = User.pwcrypt(@password)
        redirect @ruri
      elsif @rpw.size > 0
        if @rpw == @password
          usr = User.create(ut => @username, :passwd => User.pwcrypt(@password))
          session[:logged_in] = true
          session[:username] = @username
          session[:password] = User.pwcrypt(@password)
          redirect @ruri                  
        else 
          @login_failed = true          
          flash[:error] = "Passwords dont match!"
        end

      else
        flash[:error] = "Unknown Username-Password combination"
        @login_failed = true
      end
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
