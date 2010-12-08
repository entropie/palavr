#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class Integer
  def days
    self*86400
  end
end

class Time
  
  # stolen and adapted from rails / ramaze ;)
  def ago(to_time = Time.now, include_seconds = false)
    from_time = self
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round if include_seconds

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
      case distance_in_seconds
      when 0..4   then 'few seconds'
      when 5..9   then 'few seconds'
      when 10..19 then 'few seconds'
      when 20..39 then 'about a minute'
      when 40..59 then 'about a minute'
      else             '1 minute'
      end

    when 2..44           then "#{distance_in_minutes} minutes"
    when 45..89          then 'about an hour'
    when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} hours"
    when 1440..2879      then 'about a day'
    when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
    when 43200..86399    then 'about a month'
    when 86400..525959   then "#{(distance_in_minutes / 43200).round} month"
    when 525960..1051919 then 'about a year'
    else                      "over #{(distance_in_minutes / 525960).round} years"
    end
  end
  
  def iso_cweek
    thursday = self.beginning_of_week + 3.days
    (thursday.yday - (Time.mktime(thursday.year, 1, 4).beginning_of_week + 3.days).yday)/ 7 + 1
  end

  def beginning_of_week
    days_to_monday = self.wday!=0 ? self.wday-1 : 6
    self - days_to_monday.days
  end
  
  def kw
    strftime("%W")
  end

  def to_datepicker
    strftime("%m/%d/%Y")
  end

  def ykw
    strftime("%Y") + iso_cweek.to_s
  end

  def to_s(wago = true)
    if wago
      ago(Time.now, true) + " ago"
    else
      strftime("%d %b. %y")
    end
  end
  
  def nts
    strftime("%Y%m%d")
  end

  def de_short
    strftime("%d.%m")
  end

  def t2date
    strftime("%d.%m.%Y")
  end

  def getutc
    Time.utc(self.year, self.month, self.day)
  end

  # returns next day
  def next_day
    d = self + (24*60*60)
    Time.utc(d.year, d.month, d.day)
  end


  # returns a list of days between +self+ and +o+.
  # the block argument is optional.
  def days(o, &blk)
    o = o.next_day
    odate = Time.utc(o.year, o.month, o.day)
    ostart = Time.utc(self.year, self.month, self.day)
    ret, c = [], ostart
    loop{
      ret << c
      c = c.next_day
      break if c == odate
    }
    ret.each(&blk) if block_given?
    ret
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
