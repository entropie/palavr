#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"
require '../../ramaze/lib/ramaze'
require "../lib/palavr"

module GLog
  def self.<<(str, type = :debug)
    Ramaze::Log.send(type, str)
  end

  def log(str, type = :debug)
    GLog.<<(str, type)
  end
end
extend GLog


controller = %w"css palavr auth board thread".map{ |lib|
  File.join("controller", lib)
}
#libs = %w"lib".map{|lib| lib }
libs = []

class Innate::Session
  public :cookie
end
(controller + libs).each{|lib| require lib}



puts "\n%s starts up\n\n" % Palavr.version if __FILE__ == $0

if `hostname`.strip == "t2062.greatnet.de"
  Ramaze.start(:host => "t2062.greatnet.de",
               :port => 8090)
else
  Ramaze.start(:host => "localhost",
               :port => 8080)
end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
