class AddSubCharacterToFileOptions < ActiveRecord::Migration
  def change
    add_column :file_options, :sub_character, :string, default: ''
  end
end
