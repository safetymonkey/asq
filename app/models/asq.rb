# the base model for the app. Contains a query, and metadata on the query.

class Asq < ActiveRecord::Base
  include ActiveModel::Validations
  # Constants
  enum query_type: [:monitor, :report]
  enum status: {
    alert_new: 0,
    alert_still: 1,
    clear_new: 2,
    clear_still: 3,
    operational_error: 4
  }

  attr_accessor :current_user

  # Association macros
  belongs_to :database

  has_many :schedules, dependent: :destroy
  has_many :interval_schedules, dependent: :destroy
  has_many :daily_schedules, dependent: :destroy
  has_many :weekly_schedules, dependent: :destroy
  has_many :monthly_schedules, dependent: :destroy
  has_many :deliveries, dependent: :destroy
  has_many :email_deliveries, dependent: :destroy
  has_many :direct_ftp_deliveries, dependent: :destroy
  has_many :direct_sftp_deliveries, dependent: :destroy
  has_many :json_deliveries, dependent: :destroy
  has_many :activities, as: :actable
  has_many :zenoss_deliveries, dependent: :destroy

  has_one :file_options, dependent: :destroy

  # Nested attribute macros
  accepts_nested_attributes_for :schedules,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :file_options,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :deliveries,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :email_deliveries,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :direct_ftp_deliveries,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :direct_sftp_deliveries,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :json_deliveries,
                                reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :zenoss_deliveries,
                                reject_if: :all_blank, allow_destroy: true

  # Validation macros
  validates :name, uniqueness: { case_sensitive: false }
  validates :alert_value, presence: true, if: :monitor?

  # Callback macros
  before_create :set_defaults

  # Gem related macros
  acts_as_taggable

  has_paper_trail ignore: [:last_run, :status, :result,
                           :related_tickets, :modified_by,
                           :modified_on,
                           :refresh_in_progress, :query_run_time]

  # contains the application-level logic to determine if the monitor is in error
  def in_alert?
    return true if status == 'alert_new' || status == 'alert_still'
    false
  end

  def formerly_in_alert?
    return true if status == 'alert_still' || status == 'clear_new'
    false
  end

  def operational_error?
    status == 'operational_error'
  end

  # Convert the SQL Result JSON to CSV for easy downloading of the full results
  def to_csv
    FileOutputService.to_csv(result, file_options)
  end

  def results
    # return [{ 'error_source' => 'Asq', 'error_text' => 'No results are ' \
    #   'available for this Asq.' }].to_json unless result
    return '{}' unless result
    result
  end

  # Refresh the asq
  def refresh(deliver = false)
    if refresh_in_progress?
      logger.info "A refresh was requested for Asq #{name}, but one was " \
        'already in progress.'
    elsif disabled?
      logger.info "A refresh was requested for Asq #{name}, but Asq is " \
        'disabled.'
    else
      start_refresh
      Refresher.refresh(id, deliver)
    end
  end

  # Set the asq to be clear, aka not in error
  def clear
    if in_alert?
      self.status = 'clear_new'
      log('info', 'Asq alert has cleared')
    elsif operational_error?
      self.status = 'clear_new'
      log('info', 'Asq operational error has cleared')
    else
      self.status = 'clear_still'
      # self.result = ''
      self.related_tickets = nil
      finish_refresh
    end
  end

  def store_results(message)
    self.result = message.gsub(/<|\\u003c/, '').gsub(/>|\\u003e/, '')
    self.last_run = Time.now
    save
  end

  # set the moniter to be in alert:
  def alert(message)
    Delayed::Worker.logger.debug "Setting Asq #{id} to be in alert."

    if in_alert?
      self.status = 'alert_still'
    else
      self.status = 'alert_new'
      log('warn', 'Asq is in alert')
    end

    store_results(message)
    check_for_related_tickets(self) if Settings.related_tickets
    finish_refresh
  end

  # Set the asq to be in operational error (for when the service goes wacky)
  def operational_error(message = [{
    'error_source' => 'Asq',
    'error_text' => 'Something went wrong.'
  }].to_json)
    self.status = 'operational_error'
    store_results(message)
    log('error', JSON.parse(message)[0]['error_text'])
    finish_refresh
  end

  def log(level, detail)
    activity = Activity.create(activity_type: level, detail: detail)
    activities << activity
    activity
  end

  # start_refresh and stop_refresh bookend the refresh process so that we can
  # block the  asq from triggering multiple simultaneous updates.
  def start_refresh
    self.refresh_in_progress = true
    save
  end

  def finish_refresh
    return false unless refresh_in_progress
    self.refresh_in_progress = false
    save
    log('debug', 'Refresh complete')
  end

  def cancel_refresh
    # Find a job by using a ridiculous string match, unless there's an
    # easier way to match up an asq with its delayed job.
    jobs = Delayed::Job.where("handler SIMILAR TO '%ActiveRecord:Asq\n  \
      attributes:\n    id: #{id}\n%'")
    # Delete the job, if we found one
    jobs.each(&:destroy)
    finish_refresh
  end

  def needs_refresh?
    true if overdue? && (!disable_auto_refresh || !in_alert?)
  end

  # A getter method which returns the processed custom filename
  def get_processed_filename
    # We can make this if statement a single line, but then it'd be too long.
    filename = if file_options.nil? || file_options[:name].blank?
                 name + '.csv'
               else
                 file_options[:name]
               end
    if filename =~ /\Ay#/
      date = Date.today.advance(days: -1)
      return date.strftime(filename[2..-1])
    else
      date = Date.today
      return date.strftime(filename)
    end
  end

  # A getter method which returns the raw custom filename; included for
  # consistency with retrieveal of processed filename above
  def raw_filename
    return filename unless filename.blank?
    name + '.csv'
  end

  private

  # Things get a little weird if we don't set default values on new asqs
  def set_defaults
    self.last_run ||= '1999-9-9  00:00:00 UTC'
    self.status ||= 3
    self.query_run_time ||= 0
    self.alert_value ||= '0'
  end

  # Returns whether any of an Asqs scheduled runtimes are overdue
  def overdue?
    schedules.each do |schedule|
      # date the next scheduled occurence should be calculated from
      calc_date = [last_run, modified_on || created_on].max
      next_occurence = schedule.get_scheduled_date(calc_date)
      logger.debug "Next scheduled occurence for schedule id \
        #{schedule.id} is #{next_occurence}"
      return true if next_occurence < Time.now
    end
    false
  end

  # The way you handle the result_hash is standardized, so let's DRY it out
  def process_monitor_results(result_array_of_hashes, asq)
    result_array_of_hashes =
      result_array_of_hashes[0..Settings.result_limit.to_i]

    Delayed::Worker.logger.debug "Processing #{asq.name}"
    Delayed::Worker.logger.debug "Evaluating if #{asq.alert_result_type} ' \
      #{asq.alert_operator} #{asq.alert_value}"

    if asq.alert_result_type == 'rows_count'
      Delayed::Worker.logger.debug "Row length: " \
        "#{result_array_of_hashes.length} // Error value: #{asq.alert_value.to_i}"
      if result_array_of_hashes.length.send(alert_operator,
                                            asq.alert_value.to_i)
        then asq.alert(result_array_of_hashes.to_json)
      else asq.clear
      end
    elsif asq.alert_result_type == 'result_value'
      if result_array_of_hashes.length != 1
        asq.operational_error([{
          'error_source' => 'Asq', 'error_text' =>
          'Error processing results:'\
          'Expected query result with a single value.'
        }].to_json)
        asq.finish_refresh
        return
      end
      Delayed::Worker.logger.debug 'Result to evaluate: ' \
        "#{result_array_of_hashes[0].values[0]} " \
        "(#{result_array_of_hashes[0].values[0].class}) // \n" \
        "Error value: #{asq.alert_value} (#{asq.alert_value.class})"
      if (['<', '<=', '>', '>='].include? asq.alert_operator) &&
         (asq.alert_value =~ /\D/)
        asq.operational_error([{
          'error_source' => 'Asq',
          'error_text' => 'Error processing results: This Asq is ' \
          'using a less than or greater than operator against a non-numeric ' \
          'expected result. For non-numeric results, only the == and != ' \
          'operators are valid.'
        }].to_json)
      else
        result = result_array_of_hashes[0].values[0]
        alert_value = asq.alert_value
        if result != ~ /[a-zA-Z]/
          result = result.to_f
          alert_value = alert_value.to_f
        else
          result = result.to_s
          alert_value = alert_value.to_s
        end

        if result.send(alert_operator, alert_value)
          then asq.alert(result_array_of_hashes.to_json)
        else asq.clear
        end
      end
    else
      asq.operational_error([{
        'error_source' => 'Asq',
        'error_text' => 'Error processing results: ' \
        'I tried to evaluate if this Asq was in error but I ' \
        'couldn\'t understand if I was supposed to look at the row count or ' \
        'result set.'
      }].to_json)
    end
    asq.finish_refresh
  rescue StandardError => e
    asq.operational_error([{
      'error_source' => 'Asq',
      'error_text' => "Error when processing results: #{e}"
    }].to_json)
  end

  # The way you handle the result_hash is standardized, so let's DRY it out
  def process_report_results(result_array_of_hashes, asq)
    Delayed::Worker.logger.debug "Processing #{asq.name}"
    asq.store_results(result_array_of_hashes.to_json)
    # if asq was previously in operational error, now's the time to clear it:
    asq.clear
    asq.finish_refresh
  end

  # The original implementation of the related tickets check was very specific
  # to Marchex, but instead of removing it altogether we've left empty hooks in
  # so you can see how to implement ticket system checks yourself. The below
  # code, while not commented, will never display unless you un-hide the
  # related_tickets_check in views/settings/index.html.erb and change from the
  # default value of false.
  def check_for_related_tickets(asq)
    if query_type == 'report'
      asq.related_tickets = nil
      return
    end
    config = YAML.load_file('config/database.yml')['ticketing']
    # Our ticketing system (RT) was backed by Postgres, but obviously you can
    # change this up if needed.
    client = PG.connect(dbname: config['database'], host: config['host'],
                        user: config['username'], password: config['password'])

    # Your query will likely vary; we once again left ours in as an example
    query = "select array_to_json(array_agg(row_to_json(t))) from (
      SELECT id, owner FROM reporting.tickets
      WHERE status IN ('open', 'new')
      AND subject LIKE '%#{asq.name}'
      UNION ALL
      SELECT id, owner FROM reporting.vw_rt_prod_reports
      WHERE status IN ('open', 'new')
      AND subject LIKE '%#{asq.name}'
      ) t;"

    results = client.exec_params(query)
    asq.related_tickets = results.values[0][0]
    asq.save
  rescue StandardError => e
    asq.related_tickets = "Error when looking up related tickets: #{e}"
    asq.save!
  ensure
    client.close unless client.nil?
  end

  # end private
end
