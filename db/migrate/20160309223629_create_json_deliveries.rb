class CreateJsonDeliveries < ActiveRecord::Migration
  def change
    create_table :json_deliveries do |t|
      t.string :url
      t.integer :asq_id
      t.index :asq_id
      t.timestamps
    end
  end
end
