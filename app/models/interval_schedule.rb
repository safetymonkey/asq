class IntervalSchedule < Schedule
  belongs_to :asq
  validates :param, exclusion: { in: [0, nil], message: "Schedules with intervals of zero are not allowed." }

  def get_scheduled_date(from_time = Time.now.gmtime.round)
    return false unless param

    report_interval = param
    sched_time = from_time.round
    sched_time + report_interval * 60
  end
end
