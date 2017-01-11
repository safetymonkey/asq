class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :login,              null: false, default: ""
      t.string :email,              null: false, default: ""
      t.string :name,               null: false, default: ""
      t.string :firstname,          null: false, default: ""
      t.string :lastname,           null: false, default: ""
      t.string :remember_token,     null: true, default: ""
      t.boolean :is_admin,          null: false, default: false
      t.boolean :is_editor,         null: false, default: false

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.timestamps
    end

    add_index :users, :login, :unique => true
  end
end
