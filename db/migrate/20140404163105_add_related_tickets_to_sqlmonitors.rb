class AddRelatedTicketsToSqlmonitors < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :related_tickets, :string
  end
end
