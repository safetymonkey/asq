# This mixin provides the main functionality for "deliverables". It should be
# included in all deliverable classes.
module DeliverableModule
  extend ActiveSupport::Concern

  # Internal: Deliver the results of an Asq query by routing to one of three
  # private methods for reports, alarms, and all-clears. The specifics of
  # what we communicate may be different for all three of these types.
  #
  # Examples
  #
  #   delivery.deliver
  #   # => nil
  #
  # Doesn't return anything.
  def deliver
    return false unless meets_requirements?
    _deliver
    true
  end

  # Method used to determine if a delivery should archive a file. Defaults to
  # true, is meant to be overwritten by implementing deliveries if needed. Must
  # remain public.
  def should_archive_file?
    true
  end

  # Method used to determine if a delivery should logged. Defaults to
  # true, is meant to be overwritten by implementing deliveries if needed. Must
  # remain public.
  def should_log?
    return false if @skip_logging
    true
  end

  private

  def _deliver
    if should_deliver_report?
      deliver_report
    elsif should_deliver_alarm?
      deliver_alarm
    elsif should_deliver_clear?
      deliver_clear
    else
      raise 'Asq is in an unhandled state'
    end
  end

  # Internal: Deliver the results of an Asq query of the report type.
  #
  # Examples
  #
  #   delivery.deliver_report
  #   # => nil
  #
  # Doesn't return anything.
  def deliver_report
    # The base class is just a stub and doesn't need to do anything.
  end

  # Internal: Deliver the results of an Asq query of the monitor type when
  # the alarm conditions are met.
  #
  # Examples
  #
  #   delivery.deliver_alarm
  #   # => nil
  #
  # Doesn't return anything.
  def deliver_alarm
    # In the base stub class, just route these to the report method.
    deliver_report
  end

  # Internal: Deliver the results of an Asq query of the monitor type when
  # the alarm conditions indicate no alarm.
  #
  # Examples
  #
  #   delivery.deliver_clear
  #   # => nil
  #
  # Doesn't return anything.
  def deliver_clear
    # In the base stub class, just route these to the report method.
    deliver_report
  end

  # Adds an individual delivery to the asq's delivery collection
  def create_delivery
    Delivery.create(
      deliverable: self,
      asq: asq
    )
  end

  # Destroys this delivery's "parent" delivery so that we don't have Email
  def destroy_delivery
    Rails.logger.info "Attempting to destroy deliverable_id = #{id} " \
      "AND deliverable_type = '#{self.class}'"
    Delivery.where("deliverable_id = #{id} AND deliverable_type = " \
      "'#{self.class}'").each(&:destroy)
  end

  def meets_requirements?
    return true if should_deliver? && meets_sub_requirements?
    Delayed::Worker.logger.info 'Requirements not met or no delivery needed' \
      " for #{self.class} #{id}"
    false
  end

  def should_deliver?
    return false if asq.operational_error?
    return false unless should_deliver_report? || should_deliver_alarm? \
      || should_deliver_clear?
    true
  end

  def meets_sub_requirements?
    true
  end

  def should_deliver_report?
    asq.report?
  end

  def should_deliver_alarm?
    return false unless asq.monitor?
    return true if asq.status == 'alert_new'
    return true if asq.in_alert? && asq.deliver_on_every_refresh?
    false
  end

  def should_deliver_clear?
    return false unless asq.monitor?
    asq.status == 'clear_new' && asq.deliver_on_all_clear
  end
end
