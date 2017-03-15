class AutosftpDelivery < ActiveRecord::Base
  include DeliverableModule
  belongs_to :asq

  after_create :create_delivery
  after_save :delete_if_empty
  after_destroy :destroy_delivery

  private

  # In the case of deliver_report, emails don't currently have a concept of
  # reports so we're just re-routing this to deliver_alarm, which is the
  # prerequisite condition to send anything at all.
  def deliver_report
    filename = prefix + '.' + asq.get_processed_filename
    Delayed::Worker.logger.debug "Delivering #{filename} to #{Settings.autosftp_path}"
    FileDeliveryService.write_to_local_file(
      Settings.autosftp_path,
      filename,
      asq.to_csv
    )
  end

  # Call the AsqMailer directly with the parent Asq
  def deliver_alarm
    deliver_report
  end

  # Call the AsqMailer directly with the parent Asq
  def deliver_clear
    false
  end

  # Delete this object if all the attributes in it are empty.
  def delete_if_empty
    destroy if prefix.blank?
  end

  def meets_sub_requirements?
    !prefix.blank?
  end
end
