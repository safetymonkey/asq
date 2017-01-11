class AddDirectFtpDeliveries < ActiveRecord::Migration
  def change
    create_table :direct_ftp_deliveries do |t|
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
