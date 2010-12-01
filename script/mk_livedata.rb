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
    usr = User.find_or_create(:email => aemail.strip, :passwd => User.pwcrypt("test"))
    phread = Phread.create(:title => title, :body => file_contents.join("\r\n"))
    cat = Category[catid.to_i-1]
    cat.add_phread(phread)
    usr.add_phread(phread)


    # very special case
    if title.strip =~ /^Die Zarin der/
      ["poetry", "surrealism"].each {|t|
        tag = Tag.find_or_create(:tag => t)
        phread.add_tag(tag)
      }
      # on request
      phread.created_at = Time.mktime(1992, 5, 13)

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
