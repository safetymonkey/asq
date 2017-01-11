class DailySchedule < Schedule
  belongs_to :asq

  def get_scheduled_date(from_time = Time.now.gmtime.round)
    return false unless time # This would signify an incomplete state.

    sched_time = ActiveSupport::TimeZone.new(time_zone).parse(from_time.strftime "%Y-%m-%d" + " " + time).utc
    #sched_time = time.round
    report_time = Time.gm(from_time.year, from_time.month, from_time.day, sched_time.hour, sched_time.min)

    # 86,400 is the number of seconds in a day (60 * 60 * 24)
    report_time += 86_400 if report_time < from_time

    report_time
  end
end
