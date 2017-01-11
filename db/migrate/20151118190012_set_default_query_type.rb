class SetDefaultQueryType < ActiveRecord::Migration
  def up
    Asq.all.each do |asq|
      asq.query_type = 0 if asq.query_type.nil?
      asq.save
    end
    change_column_default :asqs, :query_type, 1
  end
end
