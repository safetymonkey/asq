class MonthlySchedule < Schedule
  belongs_to :asq
  def get_scheduled_date(from_time = Time.now.gmtime.round)
    return false if !param || !time

    sched_time = ActiveSupport::TimeZone.new(time_zone).parse(from_time.strftime "%Y-%m-%d" + " " + time).utc
    report_day = param # day of month schedule should run
    last_day = Date.new(from_time.year, from_time.month, -1).day # last day of from_time's month
    # diff_day = day of last_run's month a report will run
    report_day > last_day ? diff_day = last_day : diff_day = report_day
    report_time_this_month = Time.gm(from_time.year, from_time.month, diff_day,
                                     sched_time.hour, sched_time.min)
    # Get difference between last_run's month's scheduled time and last_run to
    # see if it has passed
    time_difference_in_min = (report_time_this_month - from_time) / 60

    # store the year in a variable so that we can change it in the logic to follow:
    report_year = from_time.year

    # If the difference is negative, schedule occurred before last run;
    # increment month
    if time_difference_in_min < 0
      if from_time.month + 1 > 12
        report_month = from_time.month - 11
        report_year +=1
      else
        report_month = from_time.month + 1
      end
    else
      report_month = from_time.month
    end
    # if requested day of month is beyond the last day of month, use last day
    report_day > Date.new(from_time.year, report_month, -1).day ? report_day = Date.new(from_time.year, report_month, -1).day : report_day
    Time.gm(report_year, report_month, report_day, sched_time.hour, sched_time.min)
  end
end
