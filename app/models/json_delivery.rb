# This class handles posting results in JSON format
# to the delivery's URL property.
class JsonDelivery < ActiveRecord::Base
  include DeliverableModule

  belongs_to :asq

  after_create :create_delivery
  after_save :delete_if_empty
  after_destroy :destroy_delivery

  private

  def deliver_report
    RestClient.post url, { name: asq.name, results: asq.result }.to_json,
                    content_type: :json
  end

  def deliver_alarm
    deliver_report
  end

  def deliver_clear
  end

  def delete_if_empty
    destroy if url.blank?
  end

  def meets_sub_requirements?
    !url.blank?
  end
end
