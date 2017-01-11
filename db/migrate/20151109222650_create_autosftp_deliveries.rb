class CreateAutosftpDeliveries < ActiveRecord::Migration
  def change
    create_table :autosftp_deliveries do |t|
      t.string :prefix
      t.integer :asq_id

      t.index :asq_id
    end
  end
end
