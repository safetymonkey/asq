class ReplaceSettings < ActiveRecord::Migration
  def change
  	remove_column :settings, :thing_id
  	remove_column :settings, :thing_type
  	execute "update settings set value = '' where value is null;"
    change_column_null :settings, :value, false
  end
end
