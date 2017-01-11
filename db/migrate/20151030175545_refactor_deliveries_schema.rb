class RefactorDeliveriesSchema < ActiveRecord::Migration
  def change
    # Could never quite get the below line working right. When you run this
    # migration you'll need to delete any prior existing Delivery objects.
    # Delivery.all.each(&:destroy)

    create_table :email_deliveries do |t|
      t.string :to, :from, :subject
      t.text :body
      t.integer :asq_id
      t.boolean :attach_results

      t.index :asq_id
    end

    change_table :deliveries do |t|
      t.integer :deliverable_id, null: false, default: 0
      t.string :deliverable_type, null: false, default: 'None'

      t.index :deliverable_id
      t.index :deliverable_type
    end

    reversible do |direction|
      direction.up do
        Asq.all.each do |asq|
          asq.email_deliveries.create(to: asq.email_to, attach_results: asq.email_attachment) if asq.email_alert
          # email = asq.email_deliveries.first
        end
        drop_table :email_templates
      end

      direction.down do
        puts 'WARNING! This migration isn\'t TRULY reversible. The dropped email_templates ' \
        'table gets recreated but data isn\'t migrated backwards. Additionally, ' \
        'you may need to delete any items in the Delivery table before you ' \
        'roll forward again.'

        create_table :email_templates do |t|
          t.string :subject
          t.text :body
          t.integer :asq_id
          t.timestamps
        end
      end
    end

    remove_column :deliveries, :params, :text
  end
end
