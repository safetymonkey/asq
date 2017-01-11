class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :subject
      t.text :body
      t.integer :asq_id
      t.timestamps
    end

    add_index :email_templates, :asq_id
  end
end
