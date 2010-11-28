#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "lib/palavr"
require "faker"


include Palavr::Database::Tables

def make_para
  str = ''
  0.upto(10 + rand(10)) do
    str << Faker::Lorem.paragraph(5+rand(10)) + "\r\n\r\n"
  end
  str
end


def add_tag(phread)
  0.upto(rand(3)+1) do
    tag = %w'foo bar baz geheim toll schlecht kagge uber uberuber true false bum batz'.sort_by{rand}.first
    t = Tag.find_or_create(:tag => tag)
    phread.add_tag(t) unless phread.tags.include?(t)
  end
end


letters = "abcdefghijklmnopqrstuvwxyz".scan(/./)

s=User.create(
              :email => "system@syst.em",
              :passwd => User.pwcrypt("system"),
              :name  => "root"
              
              )
s.save
me=User.create(
               :email => "mictro@gmail.com",
               :passwd => User.pwcrypt("foo"),
               :name  => "Michael Trommer"
               )
me.save

0.upto(50) do
  fname, lname = Faker::Name.first_name, Faker::Name.last_name
  
  u=User.create(:email => Faker::Internet.email(lname), :passwd => User.pwcrypt("foo"), :name => "#{fname} #{lname}")
  u.save
end


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
  thread.body = make_para
  thread.op = User[rand(50)] || me
  thread.save
  add_tag(thread)
  cats.sort_by{rand}.first.add_phread(thread)
end


0.upto(30) do
  parent = Phread[rand(25)] || Phread.first
  thread = Phread.create(:title => Faker::Lorem.sentence[0..-2])
  thread.body = make_para
  thread.op = User[rand(50)] || me
  thread.save
  add_tag(thread)
  parent.add_phread(thread)
  parent.save
end

parent = Phread[1].phreads.first rescue Phread[2].phreads.first
thread = Phread.create(:title => Faker::Lorem.sentence[0..-2])
thread.body = make_para
thread.op = User[rand(50)] || me
add_tag(thread)
thread.save
parent.add_phread(thread)


phreads = Phread.all
ps = phreads.size
User.all.each do |usr|
  phreads.sort_by{rand}.last(rand(phreads.size) / (rand(3)+1)).each do |phr|
    usr.like(phr)
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
