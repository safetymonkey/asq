# delivery class for direct ftp deliveries
class GraphiteDelivery < ActiveRecord::Base
  include DeliverableModule
  belongs_to :asq

  after_create :create_delivery
  after_save :delete_if_empty
  after_destroy :destroy_delivery

  private

  def deliver_report
    result_hash = JSON.parse(asq.result)
    unless result_hash.size == 1
      raise 'Graphite deliveries expect single row results'
    end

    client = build_client
    result_hash.each do |result|
      result.each do |key, value|
        client.add_metric(key, value.to_f)
      end
    end
  end

  def deliver_alarm
    delivery_report
  end

  def deliver_clear
    deliver_report
  end

  def delete_if_empty
    destroy if host.blank? && port.blank?
  end

  def meets_sub_requirements?
    !host.blank? && !port.blank?
  end

  def build_client
    GraphiteClient.new(host, port, prefix)
  end
end
