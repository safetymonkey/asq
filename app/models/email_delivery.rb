# Email delivery class meant to belong to an asq and use deliverable module
class EmailDelivery < ActiveRecord::Base
  include DeliverableModule
  belongs_to :asq

  after_create :create_delivery
  after_save :delete_if_empty
  after_destroy :destroy_delivery

  # Only archive files if file was attached to email
  def should_archive_file?
    @should_archive || false
  end

  private

  # In the case of deliver_report, emails don't currently have a concept of
  #   reports so we're just re-routing this to deliver_alarm, which is the
  #   prerequisite condition to send anything at all.
  def deliver_report
    AsqMailer.send_report_email(asq, self)
    @should_archive = true if attach_results == true
  end

  # Call the AsqMailer directly with the parent Asq
  def deliver_alarm
    AsqMailer.send_alert_email(asq, self)
    @should_archive = true if attach_results == true
  end

  # Call the AsqMailer directly with the parent Asq
  def deliver_clear
    AsqMailer.send_alert_cleared_email(asq, self) if asq.deliver_on_all_clear
  end

  # Delete this object if all the attributes in it are empty.
  def delete_if_empty
    destroy if default?
  end

  def meets_sub_requirements?
    !to.empty?
  end

  def default?
    [to, from, subject, body, attach_results].each do |att|
      return false unless att.blank? || att == false
    end
    true
  end
end
