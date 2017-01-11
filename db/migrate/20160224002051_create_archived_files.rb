class CreateArchivedFiles < ActiveRecord::Migration
  def change
    create_table :archived_files do |t|
      t.string :name
      t.references :activity, index: true
      t.timestamps
    end
  end
end
