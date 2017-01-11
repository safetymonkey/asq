# This migration will create the SFTP Deliveries needed for direct
# SFTP deliveries. Shocking.
class AddDirectSftpDeliveries < ActiveRecord::Migration
  def change
    create_table :direct_sftp_deliveries do |t|
      t.string :host
      t.integer :port
      t.string :directory
      t.string :username
      t.text :password
      t.integer :asq_id
      t.index :asq_id
      t.timestamps
    end
  end
end
