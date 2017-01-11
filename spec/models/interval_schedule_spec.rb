require 'rails_helper'

RSpec.describe IntervalSchedule do
  let(:schedule) { IntervalSchedule.new() }

  it "returns false next date when empty" do
    expect(schedule.get_scheduled_date).to be_falsy
  end

  it "returns date for populated schedule" do
    schedule.param = 0
    expect(schedule.get_scheduled_date).to be_a(Time)
  end

  it "returns correct date/time for given last_time" do
    schedule.param = 100
    last_run = Time.gm(2015,01,01,4)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015,1,1,05,40))
  end

  it "returns correct date/time for given last_time on following day" do
    schedule.param = 1450
    last_run = Time.gm(2015,01,01,4)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015,1,2,04,10))
  end

  it "returns correct date/time for given last_time on following month" do
    schedule.param = 1450
    last_run = Time.gm(2015,02,28,4)
    expect(schedule.get_scheduled_date(last_run)).to eq(Time.gm(2015,3,1,04,10))
  end

end