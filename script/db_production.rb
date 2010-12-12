#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "lib/palavr"
require "faker"


include Palavr::Database::Tables

s=User.create(
              :email => "system@syst.em",
              :passwd => User.pwcrypt("system"),
              :name  => "root",
              :nick  => "Gott",
              :admin => 1,
              :mod   => 1
              
              )
s.save

me=User.create(
               :email => "mictro@gmail.com",
               :passwd => User.pwcrypt("foo"),
               :name  => "Michael Trommer",
               :nick  => "entropie"
               :admin => 1,
               :mod   => 1
               )
me.save



cats = []


a=Category.create(:title => "Fantasy",
                  :description => Faker::Lorem.paragraph)
a.add_mod(me)
a.add_mod(s)
a.save
cats << a

b=Category.create(:title => "Science Fiction",
                  :description => Faker::Lorem.paragraph)
b.add_mod(me)
b.save
cats << b


b=Category.create(:title => "Horror & Thriller",
                  :description => Faker::Lorem.paragraph)
b.add_mod(me)
b.save
cats << b

b=Category.create(:title => "Other",
                  :description => Faker::Lorem.paragraph)
b.add_mod(me)
b.save
cats << b


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
