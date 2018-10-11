class AddGraphiteDelivery < ActiveRecord::Migration[5.0]
  def change
    create_table :graphite_deliveries do |t|
      t.belongs_to :asq
      t.string :host
      t.string :port
      t.string :prefix

      t.timestamps
    end
  end
end
