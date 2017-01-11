class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.references :asq, index: true
      t.text :params

      t.timestamps
    end
  end
end
