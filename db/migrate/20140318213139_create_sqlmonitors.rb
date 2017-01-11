class CreateSqlmonitors < ActiveRecord::Migration
  def change
    create_table :sqlmonitors do |t|
      t.string :name
      t.text :description
      t.text :query
      t.belongs_to :database
      t.integer :run_frequency, null: false, default: 5
      t.timestamp :last_run, null: false, default: '1999-9-9  00:00:00 UTC'
      t.boolean :in_error
      t.integer :expected_rows, null: false, default: 0
      t.text :result
      t.string :created_by
      t.timestamp :created_on
      t.string :modified_by
      t.timestamp :modified_on      

      t.timestamps
    end
  end
end
