class AddEmailAttachmentOptionToSqlmonitor < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :email_attachment, :boolean, :null => false, :default => true
  end
end
