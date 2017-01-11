# Renames asq.db_type, converts its value into an integer, and puts that
# value into a new db_type column. We'll delete db_type_old at a future time.
class AddDbEnums < ActiveRecord::Migration
  def up
    rename_column :databases, :db_type, :db_type_old
    add_column :databases, :db_type, :integer
    Database.find_each do |database|
      database.db_type = database.db_type_old.to_sym
      database.save!
    end
  end

  def down
    remove_column :databases, :db_type
    rename_column :databases, :db_type_old, :db_type
  end
end
