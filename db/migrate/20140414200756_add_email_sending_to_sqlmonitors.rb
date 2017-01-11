class AddEmailSendingToSqlmonitors < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :email_alert, :boolean
    add_column :sqlmonitors, :email_to, :string
  end
end
