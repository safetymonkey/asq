# This class is the module that handles pushing Zenoss alerts.
class ZenossDelivery < ActiveRecord::Base
  include DeliverableModule

  belongs_to :asq

  after_create :create_delivery
  after_save :destroy_on_empty
  after_destroy :destroy_delivery

  private

  def deliver_alarm
    ZenossService.post(asq)
  rescue StandardError => e
    # This is a single line to do some quick logging. This wasn't part of the
    # original card, but since it's easy to do, I threw it in. Logging will
    # need to be fleshed out in a future card.
    Delayed::Worker.logger.debug("Failed to post #{asq.name} to Zenoss. /n Error: #{e}")
  end

  def deliver_clear
    deliver_alarm
  end

  def should_deliver_clear?
    return false unless asq.monitor?
    asq.status == 'clear_new'
  end

  def destroy_on_empty
    destroy unless enabled
  end

  def should_deliver_alarm?
    return false unless asq.monitor?
    return true if asq.in_alert?
    false
  end

  def meets_sub_requirements?
    return false if Settings.zenoss_enabled.blank?
    return false if Settings.zenoss_url.blank?
    true
  end
end
