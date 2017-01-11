# creating a new mapping table so that we can sort statuses non_numerically
class CreateAsqStatusSortTable < ActiveRecord::Migration
  def up
    create_table :statuses do |t|
      t.integer :status_enum
      t.integer :sort_priority

      t.timestamps
    end

    execute "insert into statuses (status_enum, sort_priority) VALUES (0, 2)"
    execute "insert into statuses (status_enum, sort_priority) VALUES (1, 3)"
    execute "insert into statuses (status_enum, sort_priority) VALUES (2, 4)"
    execute "insert into statuses (status_enum, sort_priority) VALUES (3, 5)"
    execute "insert into statuses (status_enum, sort_priority) VALUES (4, 1)"

  end

  def down
    drop_table :statuses
  end
end
