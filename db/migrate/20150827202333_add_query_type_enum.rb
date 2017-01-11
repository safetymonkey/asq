class AddQueryTypeEnum < ActiveRecord::Migration
  def change
  	add_column :asqs, :query_type, :integer
  end
end
