#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "lib/palavr"
require "faker"


include Palavr::Database::Tables



letters = "abcdefghijklmnopqrstuvwxyz".scan(/./)

s=User.create(
              :email => "system@syst.em",
              :passwd => User.pwcrypt("system")
              )
s.save
me=User.create(
               :email => "mictro@gmail.com",
               :passwd => User.pwcrypt("foo")
               )
me.save


cats = []

a=Category.create(:title => "Testing",
                  :description => Faker::Lorem.paragraph)
a.add_mod(me)
a.add_mod(s)
a.save


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


0.upto(30) do
  thread = Phread.create(:title => Faker::Lorem.sentence[0..-2])
  thread.body = Faker::Lorem.sentences(10 + rand(100))
  thread.op = me
  thread.save
  cats.sort_by{rand}.first.add_phread(thread)
end


0.upto(30) do
  parent = Phread[rand(25)] || Phread.first
  thread = Phread.create(:title => Faker::Lorem.sentence[0..-2])
  thread.body = Faker::Lorem.sentences(10 + rand(100))
  thread.op = me
  thread.save
  parent.add_phread(thread)
  parent.save
end

parent = Phread[1].phreads.first
thread = Phread.create(:title => Faker::Lorem.sentence[0..-2])
thread.body = Faker::Lorem.sentences(10 + rand(100))
thread.op = me
thread.save
parent.add_phread(thread)


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
