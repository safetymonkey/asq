require 'rails_helper'

RSpec.describe DailySchedule do
  let(:schedule) { DailySchedule.new() }

  it "returns false when the time property is empty" do
    expect(schedule.get_scheduled_date).to be_falsy
  end

  it "returns a Time object when the scheduled time and time_zone are set" do
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    expect(schedule.get_scheduled_date).to be_a(Time)
  end

  it "returns the same day as the passed-in date if last_run's time is before the scheduled time" do
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 9, 30, 11, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 9, 30, 12, 00))
  end

  it "returns the day after the passed-in date if last_run's time is after the scheduled time" do
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 9, 1, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 9, 2, 12, 00))
  end

  it "returns the first day of the following month if last_run's date is the last day of the month 
      and its time is after the scheduled time" do
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 9, 30, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 10, 1, 12, 00))
  end

end