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
      when 0..4   then 'wenigen sekunden'
      when 5..9   then 'weniger als 10 sekunden'
      when 10..19 then 'weniger als 20 sekunden'
      when 20..39 then 'einer halben minute'
      when 40..59 then 'weniger als einer minute'
      else             '1 minute'
      end

    when 2..44           then "#{distance_in_minutes} minuten"
    when 45..89          then 'einer stunde'
    when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} stunden"
    when 1440..2879      then 'einem tag'
    when 2880..43199     then "#{(distance_in_minutes / 1440).round} tagen"
    when 43200..86399    then 'einem monat'
    when 86400..525959   then "#{(distance_in_minutes / 43200).round} monaten"
    when 525960..1051919 then 'einem jahr'
    else                      "über #{(distance_in_minutes / 525960).round} jahren"
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
      ago(Time.now, true)
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
