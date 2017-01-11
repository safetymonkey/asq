class AddRefreshInProgressToSqlmonitor < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :refresh_in_progress, :boolean, :null => false, :default => false
  end
end
