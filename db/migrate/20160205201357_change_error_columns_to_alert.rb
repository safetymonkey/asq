class ChangeErrorColumnsToAlert < ActiveRecord::Migration
  def change
  	rename_column :asqs, :error_result_type, :alert_result_type
  	rename_column :asqs, :error_operator, :alert_operator
  	rename_column :asqs, :error_value, :alert_value
  end
end
