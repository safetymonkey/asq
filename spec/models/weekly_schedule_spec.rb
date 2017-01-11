require 'rails_helper'

RSpec.describe WeeklySchedule do
  let(:schedule) { WeeklySchedule.new() }

  it "returns false when the time property is empty" do
    expect(schedule.get_scheduled_date).to be_falsy
  end

  it "returns a Time object when time, time_zone, and param are set" do
    schedule.time = '00:00'
    schedule.time_zone = 'UTC'
    schedule.param = 0
    expect(schedule.get_scheduled_date).to be_a(Time)
  end

  it "returns the week after last_run if last_run occured on the same day of the week as param, but after the scheduled time" do
    schedule.time = '06:00'
    schedule.time_zone = 'UTC'

    # Ruby considers Tuesday as day 2 in a 0 - 6 sequence.
    schedule.param = 2

    # 2/3/2015 is a Tuesday.
    last_run = Time.gm(2015, 2, 3, 7, 00)

    # 2/10/2015 is a Tuesday.
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 2, 10, 6, 00))
  end

  it "returns the date in the same week as last_run if last_run's day number is the same as param 
      and if time is before the scheduled time" do
    schedule.time = '06:00'
    schedule.time_zone = 'UTC'

    # Ruby considers Tuesday as day 2 in a 0 - 6 sequence.
    schedule.param = 2

    # 2/3/2015 is a Tuesday.
    last_run = Time.gm(2015, 2, 3, 5, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 2 , 3, 6, 00))
  end

  it "returns a date in the week following the last_run, even if last_run is far in the past" do
    schedule.time = '06:00'
    schedule.time_zone = 'UTC'

    # Ruby considers Tuesday as day 2 in a 0 - 6 sequence.
    schedule.param = 2

    # 2/3/2012 is a Friday.
    last_run = Time.gm(2012, 2, 3, 5, 00)

    # 2/7/2012 is a Tuesday.
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2012, 2, 7, 6, 00))
  end

  it "returns the appropriate date if next scheduled occurence is the following month" do
    schedule.time = '06:00'
    schedule.time_zone = 'UTC'

    # Ruby considers Tuesday as day 2 in a 0 - 6 sequence.
    schedule.param = 2

    # 2/27/2015 is a Friday.
    last_run = Time.gm(2015, 2, 27, 5)

    # 3/3/2015 is a Tuesday.
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 3, 3, 6, 00))
  end

  it "returns the appropriate date if next scheduled occurence is the following month, accounting for a leap year" do
    schedule.time = '06:00'
    schedule.time_zone = 'UTC'

    # Ruby considers Tuesday as day 2 in a 0 - 6 sequence.
    schedule.param = 2

    # 2/27/2016 is a Saturday.
    last_run = Time.gm(2016, 2, 27, 5, 00)

    # 3/1/2015 is a Tuesday.
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2016, 3, 1, 6, 00))
  end

end
