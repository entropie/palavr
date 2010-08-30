#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class String

  def shorten(d = '...', s = 100)
    if size > s
      self[0..s] + " " + d
    else
      self
    end
  end

  def self.ykws(year = Time.now.year)
    ret = { }
    last  = Time.utc(year, 12, 30)
    first = Time.utc(year, 1, 1)
    weekd = 24 * 60 * 60 * 7
    loop do
      last = last - weekd
      break if last < first
      ret[last.iso_cweek] = last
    end
    ret
  end
  
  def kw_to_time
    String.ykws[self.to_i]
  end
  
  def datepicker_time
    t = self
    Time.utc(t[6..-1], t[0..1], t[3..4])
  end

  def fto_time
    t = self
    Time.utc(t[0..3], t[4..5], t[6..-1])
  end
  
  def to_time
    if self.split(".").size > 2
      d, m, y = self.split(" ").last.split(".")
      return Time.utc(y, m, d) if y and m and d
    else
      d, m, y = self.split(" ").last.split("-").reverse
      return Time.utc(y, m, d) if y and m and d
    end
    false
  end


  def cdata
    "<![CDATA[#{self}]]>"
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
