class RenameEmailAllClear < ActiveRecord::Migration
  def change
  	rename_column :asqs, :email_all_clear, :deliver_on_all_clear
 	rename_column :asqs, :email_on_every_refresh, :deliver_on_every_refresh
  end
end
