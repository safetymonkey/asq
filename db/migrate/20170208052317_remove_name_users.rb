class RemoveNameUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :name
    remove_column :users, :firstname
    remove_column :users, :lastname
  end
end
