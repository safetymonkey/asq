class DropAutoSftp < ActiveRecord::Migration
  def change
    drop_table :autosftp_deliveries
  end
end
