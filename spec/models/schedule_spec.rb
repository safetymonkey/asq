require 'rails_helper'

RSpec.describe Schedule do
  let(:schedule) { Schedule.new }

  it "returns false when get_scheduled_date is called on base class" do
    expect(schedule.get_scheduled_date).to be_falsy
  end

end