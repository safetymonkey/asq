# StatusController initializes the instance variables required for the view and
# renders appropriate content for Nagios scraping
class StatusController < ApplicationController
  def index
    vars_hash = SystemStatus.vars_hash
    @time_since_last_update = vars_hash[:time_since_last_update]
    @delayed_job_queue_size = vars_hash[:delayed_job_queue_size]
    @delayed_job_worker_count = vars_hash[:delayed_job_worker_count]
    @cron_exists = vars_hash[:cron_exists]
    @last_host_check = vars_hash[:last_host_check]
    @system_in_error = vars_hash[:system_in_error]
    @title = 'System Status'
    @asq_hostname = Rails.application.hostname
  end

  def nagios
    vars_hash = SystemStatus.vars_hash
    result = { 'system_status' => vars_hash[:error_text] }
    render json: result
  end
end
