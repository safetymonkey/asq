class RenameStatusesTable < ActiveRecord::Migration
  def up
    rename_table :statuses, :asq_statuses
  end

  def down
    rename_table :asq_statuses, :statuses
  end
end
