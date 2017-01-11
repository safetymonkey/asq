require 'rails_helper'

RSpec.describe MonthlySchedule do
  let(:schedule) { MonthlySchedule.new() }

  it "returns false when the time property is empty" do
    expect(schedule.get_scheduled_date).to be_falsy
  end

  it "returns a Time object when the scheduled time, time_zone, and param are set" do
    schedule.param = 20
    schedule.time = '00:00'
    schedule.time_zone = 'UTC'
    expect(schedule.get_scheduled_date).to be_a(Time)
  end

  it "returns the last date of the month if param is beyond the month's end" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 2, 15, 00, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 2, 28, 12, 00))
  end

  it "returns the date of last_run if last_run is on the param date, but the time has not yet passed" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 9, 30, 11, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 9, 30, 12, 00))
  end

  it "returns a date from the next month if last_run is on the param date, but the time has passed" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 9, 30, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 10, 30, 12, 00))
  end

  it "returns a date from the next year if last_run is on the param date, but the time has passed, and the month is December" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 12, 30, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2016, 1, 30, 12, 00))
  end

  it "returns the date of last_run if last_run is on the last date of the month and param is larger, but the time has not yet passed" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 2, 28, 11, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 2, 28, 12, 00))
  end

  it "returns a date from the next month if last_run is on the last date of the month, but param is larger and the time has not passed" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 2, 28, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 3, 30, 12, 00))
  end

  it "returns 2/29 during a leap year if last_run is on 2/28, but param is 30 and the time has passed" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2016, 2, 28, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2016, 2, 29, 12, 00))
  end

  it "returns 3/30 during a leap year if last_run is on 2/29, but param is 30 and the time has passed" do
    schedule.param = 30
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2016, 2, 29, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2016, 3, 30, 12, 00))
  end

  it "returns 2/29 during a leap year if last_run is on 2/29 and param is 29, but the time has not passed" do
    schedule.param = 29
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2016, 2, 29, 11, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2016, 2, 29, 12, 00))
  end

  it "returns 3/29 during a leap year if last_run is on 2/29 and param is 29, but the time has passed" do
    schedule.param = 29
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2016, 2, 29, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2016, 3, 29, 12, 00))
  end

  it "returns 3/29 during a non-leap year if last_run is on 2/28 and param is 29, but the time has passed" do
    schedule.param = 29
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 2, 28, 13, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 3, 29, 12, 00))
  end

  it "returns 2/28 during a non-leap year if last_run is on 2/28 and param is 29, but the time has not passed" do
    schedule.param = 29
    schedule.time = '12:00'
    schedule.time_zone = 'UTC'
    last_run = Time.gm(2015, 2, 28, 11, 00)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015, 2, 28, 12, 00))
  end

end