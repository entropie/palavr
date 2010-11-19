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


a=Category.create(:title => Faker::Lorem.sentence,
                  :description => Faker::Lorem.paragraph)
a.add_mod(me)
a.add_mod(s)
a.save

b=Category.create(:title => Faker::Lorem.sentence,
                  :description => Faker::Lorem.paragraph)
b.add_mod(me)
b.save


b=Category.create(:title => Faker::Lorem.sentence,
                  :description => Faker::Lorem.paragraph)
b.add_mod(me)
b.save


# thread = Phread.create(:title => Faker::Lorem.sentence)
# thread.op = me
# thread.body = Faker::Lorem.sentences(10 + rand(20))
# thread.save

# a.add_phread(thread)

# thread = Phread.create(:title => Faker::Lorem.sentence)
# thread.body = Faker::Lorem.sentences(10 + rand(100))
# thread.op = me
# thread.save


# b.add_phread(thread)
# a.add_phread(thread)


0.upto(10) do
  thread = Phread.create(:title => Faker::Lorem.sentence)
  thread.body = Faker::Lorem.sentences(10 + rand(100))
  thread.op = me
  thread.save
  a.add_phread(thread)
end

parent = Phread[1]

0.upto(10) do
  thread = Phread.create(:title => Faker::Lorem.sentence)
  thread.body = Faker::Lorem.sentences(10 + rand(100))
  thread.op = me
  thread.save
  parent.add_phread(thread)
  parent.save
end

parent = Phread[1].phreads.first
  thread = Phread.create(:title => Faker::Lorem.sentence)
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
