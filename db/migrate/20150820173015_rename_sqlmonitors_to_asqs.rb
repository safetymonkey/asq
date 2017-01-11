class RenameSqlmonitorsToAsqs < ActiveRecord::Migration
  def change
    rename_table :sqlmonitors, :asqs
    
    reversible do |dir|
      dir.up do
        ActsAsTaggableOn::Tagging.all.each do |tagging|
          tagging.taggable_type = 'Asq' if tagging.taggable_type == 'Sqlmonitor'
          tagging.save
        end
      end
      dir.down do
        ActsAsTaggableOn::Tagging.all.each do |tagging|
          tagging.taggable_type = 'Sqlmonitor' if tagging.taggable_type == 'Asq'
          tagging.save
        end
      end
    end
  end
end
