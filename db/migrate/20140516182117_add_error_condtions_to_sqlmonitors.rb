class AddErrorCondtionsToSqlmonitors < ActiveRecord::Migration
  def change
    add_column :sqlmonitors, :error_result_type, :string
    add_column :sqlmonitors, :error_operator, :string
    add_column :sqlmonitors, :error_value, :string
    remove_column :sqlmonitors, :expected_rows
  end
end
