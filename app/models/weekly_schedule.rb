class WeeklySchedule < Schedule
  belongs_to :asq
  def get_scheduled_date(from_time = Time.now.gmtime.round)
    return false if !param || !time

    # Ruby considers Sunday as day 0 in a 0 - 6 sequence.

    sched_time = ActiveSupport::TimeZone.new(time_zone).parse(from_time.strftime "%Y-%m-%d" + " " + time).utc
    report_day = param
    report_time = Time.gm(from_time.year, from_time.month, from_time.day, sched_time.hour, sched_time.min)
    diff = ((report_time - from_time) / 60) + (report_day - from_time.wday) * 24 * 60
    diff < 0 ? diff += (7 * 24 * 60) : diff
    (from_time + diff * 60).round
  end
end
