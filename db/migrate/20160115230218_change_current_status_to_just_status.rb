class ChangeCurrentStatusToJustStatus < ActiveRecord::Migration
  def change
  	rename_column :asqs, :current_status, :status
  end
end
