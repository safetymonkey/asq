# Initialize system status state variables and runs health checks
class SystemStatus
  class << self
    def vars_hash
      init_status_vars
      check_for_errors
      create_hash
    end

    private

    def create_hash
      {
        time_since_last_update: @time_since_last_update,
        delayed_job_queue_size: @delayed_job_queue_size,
        delayed_job_worker_count: @delayed_job_worker_count,
        cron_exists: @cron_exists,
        last_host_check: @last_host_check,
        system_in_error: @system_in_error,
        error_text: @error_text
      }
    end

    def dj_path
      Rails.root.join('tmp', 'pids', 'delayed_job.*')
    end

    def init_status_vars
      @time_since_last_update = time_since_last_update
      @delayed_job_queue_size = Delayed::Job.count
      @delayed_job_worker_count = Dir.glob(dj_path).count do |file|
        File.file?(file)
      end
      @cron_exists = File.exist?('/etc/cron.d/Asq')
      @last_host_check = Settings.last_host_check
      @system_in_error = false
      @error_array = []
      @error_text = ''
    end

    def time_since_last_update
      return 0 if Asq.all.empty?
      (Time.now - Asq.all.order(last_run: :desc).limit(1)[0].last_run) / 60
    end

    def process_check_result(message)
      return unless message
      @system_in_error = true
      @error_array.push(message)
    end

    def check_time_since_last_update
      if @time_since_last_update > 20
        "It has been #{@time_since_last_update.round(0)} minutes " \
          'since the last Asq refreshed.'
      end
    end

    def active_dj_workers
      active_workers = `ps aux | grep delayed | grep -v grep`.split("\n")
      active_workers.count
    end

    def check_delayed_job_worker_count
      if @delayed_job_worker_count == 0
        return 'There are no Delayed Job workers running.'
      end
      if active_dj_workers < @delayed_job_worker_count
        return "There are #{active_dj_workers} out of " \
        "#{@delayed_job_worker_count} Delayed Job workers running."
      end
    end

    def check_cron_exists
      unless @cron_exists
        'The cron file (/etc/cron.d/Asq) does not exist on this' \
          ' host.'
      end
    end

    def check_last_host_check
      'Primary host check has failed.' unless @last_host_check == 'OK'
    end

    def check_for_errors
      checks_to_perform = [
        :check_time_since_last_update,
        :check_delayed_job_worker_count,
        :check_cron_exists,
        :check_last_host_check
      ]
      # for each check, pass result to process_check_result
      checks_to_perform.each { |m| process_check_result(send(m)) }
      @error_text = @error_array.empty? ? 'HEALTHY' : @error_array.join(' ')
    end
  end
end
