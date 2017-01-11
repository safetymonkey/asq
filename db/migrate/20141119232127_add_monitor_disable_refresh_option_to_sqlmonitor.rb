class AddMonitorDisableRefreshOptionToSqlmonitor < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :disable_auto_refresh, :boolean, :null => false, :default => false
  end
end