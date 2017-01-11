class CreateActivity < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :activity_type
      t.text :detail
      t.integer :user_id
      t.integer :actable_id
      t.string :actable_type
      t.timestamps
    end
  end
end
