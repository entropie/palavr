#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "lib/palavr"

$KCODE = "UTF-8"
require "iconv"
include Palavr::Database::Tables


Dir.chdir("livedata/cats") do
  Dir.glob('**/*.txt').each do |file|
    catid, filename = file.split("/")
    file_contents = File.readlines(file).reject{|f| f.strip.empty?}
    file_contents.map!{|f| Iconv.conv('utf-8', 'ISO-8859-1', f)}

    #pp file_contents

    title = file_contents.shift
    aemail, author = file_contents.pop, file_contents.pop

    puts title
    usr = User.find_or_create(:email => aemail, :passwd=> User.pwcrypt("test125"))
    phread = Phread.create(:title => title, :body => file_contents.join("\r\n"))
    cat = Category[catid.to_i]
    cat.add_phread(phread)
    usr.add_phread(phread)


    # very special case
    if title = "Die Zarin der Pseudo-Reinkarnation"
      ["poetry", "surrealism"].each {|t|
        tag = Tag.find_or_create(:tag => t)
        phread.add_tag(tag)
      }
      phread.readonly = 1
      phread.save
    end
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
