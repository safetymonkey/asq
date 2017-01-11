class AddCustomFilenameToAsqs < ActiveRecord::Migration
  def change
    add_column :asqs, :filename, :string
  end
end
