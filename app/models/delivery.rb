# Enables us to get a polymorphic collection of deliveries for each Asq. The
# shared logic for individual delivery classes is in the module.
class Delivery < ActiveRecord::Base
  belongs_to :asq
  belongs_to :deliverable, polymorphic: true

  def deliver
    return false if deliverable_type == 'None' || deliverable.nil?
    _deliver
  end

  private

  def _deliver
    d_string = "#{deliverable_type} #{deliverable_id} for Asq " \
      "#{deliverable.asq.id}"
    Delayed::Worker.logger.debug "Starting #{d_string}"
    log_success(d_string) if deliverable.deliver
  rescue StandardError => e
    log_error(d_string, e)
  end

  def log_error(d_string, e)
    deliverable.asq.log('error', "#{deliverable_type} failed: #{e}")
    Delayed::Worker.logger.error "Error delivering #{d_string}: #{e}"
  end

  def log_success(d_string)
    return unless deliverable.should_log?
    activity = deliverable.asq.log('info', "#{deliverable_type} succeeded")
    archive_file(activity) if deliverable.should_archive_file?
    Delayed::Worker.logger.info "Delivered #{d_string}"
  end

  # method used to create an ArchiveFile and attach it to delivery. This method
  # does no further checking of whether a file SHOULD be saved; calling this
  # method implies that check has already been made.
  def archive_file(activity)
    # feature flag is set in environment files
    return unless Rails.application.feature_archive_file_enabled
    name = deliverable.asq.get_processed_filename
    content = deliverable.asq.to_csv
    activity.archive_file(name, content)
  end
end
