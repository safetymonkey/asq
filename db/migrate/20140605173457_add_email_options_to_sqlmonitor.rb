class AddEmailOptionsToSqlmonitor < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :email_on_every_refresh, :boolean
    add_column :sqlmonitors, :email_all_clear, :boolean
  end
end
