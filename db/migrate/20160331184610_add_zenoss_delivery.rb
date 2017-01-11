class AddZenossDelivery < ActiveRecord::Migration
  def change
    create_table :zenoss_deliveries do |t|
      t.integer :asq_id
      t.boolean :enabled
      t.index :asq_id
      t.timestamps
    end
  end
end
