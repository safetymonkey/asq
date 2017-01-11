class RemoveAsqJsonProperties < ActiveRecord::Migration
  def change
    Asq.all.each do |asq|
      next if asq.post_json_url.blank?
      new_json_delivery = JsonDelivery.new(url: asq.post_json_url, asq_id: asq.id)
      new_json_delivery.save!
    end
  	remove_column :asqs, :post_json_url      
    remove_column :asqs, :post_json_on_alarm
  end
end
