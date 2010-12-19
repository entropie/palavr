#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class CSSController < Ramaze::Controller # def ctrl
  map     "/css"
  provide :css, :Sass
  engine :Sass
  trait :sass_options => {
    :style => :expanded,
  } 

  GFontSet = {
    :default => {
      :neuton => [],
      :"droid sans" => [],
      :arvo         => [],
      :copse        => [],
      :orbitron     => []
    },
    :block => {
      :lobster     => [],
      :inconsolata => [],
      :philosopher => [],
      :nobile      => [],
      :puritan     => [],
      :armimo      => []      
    }
  }


  def base
  end

  def default
    "body\n  "
  end
  
  def select(which, what)
    f = GFontSet[which.to_sym]
    str = "@import url(//fonts.googleapis.com/css?family=#{what.to_s.capitalize}:regular)\n"
    what = ::CGI.escape(what.to_s)
    str <<
      case which
      when "default"
        "body\n  :font-family \"#{what}\", serif, arial !important"
      when "block"
        [".phread .body .para p", ".phread .top h1", "p"].map{|w| 
        "#{w}\n  :font-family \"#{what}\", serif, arial !important"
        }.join("\n")
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
