class ChangeErrorTypeInAsqs < ActiveRecord::Migration
  def up
    add_column :asqs, :current_status, :integer, default: 3
    # preserve the current state of the asqs before removing the in_error column
    Asq.find_each do |asq|
      next unless asq.in_error?
      asq.current_status = 0
      asq.save
    end
    remove_column :asqs, :in_error
  end

  def down
    add_column :asqs, :in_error, :boolean, default: false
    Asq.find_each do |asq|
      next unless asq.current_status == 0 || asq.current_status == 1
      asq.in_error = true
      asq.save
    end
    remove_column :asqs, :current_status
  end
end
