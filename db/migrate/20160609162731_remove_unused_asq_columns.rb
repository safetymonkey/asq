class RemoveUnusedAsqColumns < ActiveRecord::Migration
  def up
    rename_column :asqs, :updated_at, :deprecated_2016_06_28_updated_at
    rename_column :asqs, :created_at, :deprecated_2016_06_28_created_at
    rename_column :asqs, :email_to, :deprecated_2016_06_28_email_to
    rename_column :asqs, :run_frequency, :deprecated_2016_06_28_run_frequency
  end

  def down
    rename_column :asqs, :deprecated_2016_06_28_updated_at, :updated_at 
    rename_column :asqs, :deprecated_2016_06_28_created_at, :created_at
    rename_column :asqs, :deprecated_2016_06_28_email_to, :email_to
    rename_column :asqs, :deprecated_2016_06_28_run_frequency, :run_frequency
  end
end
