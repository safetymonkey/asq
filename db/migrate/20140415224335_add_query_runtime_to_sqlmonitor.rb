class AddQueryRuntimeToSqlmonitor < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :query_run_time, :float
  end
end
