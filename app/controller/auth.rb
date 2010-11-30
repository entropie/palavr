#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class AuthController < PalavrController

  set_layout("layout") # => [:index]) {|path, wish| not request.xhr? }
  
  map "/auth"
  
  def login
    pp request.params
    @ruri = request.params["ruri"]
    p @ruri
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

      if check_auth(@username, @password)
        session[:logged_in] = true
        session[:username] = @username
        session[:password] = User.pwcrypt(@password)
        redirect @ruri
      elsif @rpw.size > 0
        if @rpw == @password
          usr = User.create(:email => @username, :passwd => User.pwcrypt(@password))
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
