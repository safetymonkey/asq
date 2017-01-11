class AddPostDeliveryOptions < ActiveRecord::Migration
  def change
  	add_column :sqlmonitors, :post_json_on_alarm, :boolean
  	add_column :sqlmonitors, :post_json_url, :string
  end
end
