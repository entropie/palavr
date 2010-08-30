class Date

  def to_datepicker
    t = self
    "%02d" %t.month + "/%02d" % t.day + "/#{t.year}" 
  end
end
