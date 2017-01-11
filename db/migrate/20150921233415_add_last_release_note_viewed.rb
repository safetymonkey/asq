class AddLastReleaseNoteViewed < ActiveRecord::Migration
  def change
  	add_column :users, :last_release_note_viewed, :integer, default: 0
  end
end
