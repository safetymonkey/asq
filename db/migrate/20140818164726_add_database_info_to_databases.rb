class AddDatabaseInfoToDatabases < ActiveRecord::Migration
  def change
    add_column :databases, :hostname, :string
    add_column :databases, :username, :string
    add_column :databases, :password, :text
    add_column :databases, :db_name, :string
    add_column :databases, :port, :integer
  end
end
