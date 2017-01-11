class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :type
      t.time :time
      t.integer :param
      t.references :asq, index: true
      t.timestamps
    end
    Asq.find_each do |asq|
      if asq.run_frequency > 0
        sc = asq.schedules.new
        sc.type = 'IntervalSchedule'
        sc.param = asq.run_frequency
        sc.save
      end
    end
  end
end
