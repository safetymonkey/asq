class AddScheduleTimeZone < ActiveRecord::Migration
  def change
  	change_table :schedules do |t|
      t.rename :time, :time_old
      t.string :time
      t.string :time_zone
    end

    Schedule.find_each do |schedule|
      schedule.time = schedule.time_old.to_s(:time) unless schedule.time_old.blank?
      schedule.time_zone = 'UTC'
      schedule.save!
    end
  end
end
