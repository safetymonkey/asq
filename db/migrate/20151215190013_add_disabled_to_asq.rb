class AddDisabledToAsq < ActiveRecord::Migration
  def change
    change_table :asqs do |t|
      t.boolean :disabled
    end
  end
end
