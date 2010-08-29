#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"
require '../../ramaze/lib/ramaze'
#require '../lib/ams'

module GLog
  def self.<<(str, type = :debug)
    Ramaze::Log.send(type, str)
  end

  def log(str, type = :debug)
    GLog.<<(str, type)
  end
end
extend GLog


controller = %w"css palavr board".map{ |lib|
  File.join("controller", lib)
}
#libs = %w"lib".map{|lib| lib }
libs = []

class Innate::Session
  public :cookie
end
(controller + libs).each{|lib| require lib}



Ramaze.start(:host => "localhost",
             :port => 8080
#             :adapter => :mongrel
             )
p 1


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
