class CreateFileOptions < ActiveRecord::Migration
  def change
    create_table :file_options do |t|
      t.references :asq, index: true
      t.string :name
      t.string :line_end
      t.string :delimiter
      t.string :quoted_identifier
      t.timestamps
    end

  end
end
