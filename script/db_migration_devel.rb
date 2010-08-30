#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "lib/palavr"
require "faker"


include Palavr::Database::Tables



letters = "abcdefghijklmnopqrstuvwxyz".scan(/./)

a=User.create(
              :email => "system@syst.em",
              :passwd => User.pwcrypt("system")
              )
a.save
a=User.create(
              :email => "mictro@gmail.com",
              :passwd => User.pwcrypt("foo")
              )
a.save




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
