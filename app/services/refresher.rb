# This class gathers results and handles processing and delivering  the #
# result set for Asq.                                                   #
class Refresher
  # Currently, we take in an entire asq, which is bloated and needs
  # to be trimmed. This will not be an issue if we remove results from
  # the asq model.

  def initialize(asq_id, should_deliver = false)
    @asq = Asq.find(asq_id)
    @should_deliver = should_deliver
  end

class << self
  def refresh(asq_id, should_deliver = false)
    refresh = Refresher.new(asq_id, should_deliver)
    refresh.refresh
  end
  # NOTE: If you comment out the line below, delayed_job will be disabled.
  # This is great for troubleshooting. But for the love of God, change it back
  # before you commit your code.
  handle_asynchronously :refresh
end

  def refresh
    start_time = Time.now
    begin
      results = QueryExecutor.execute_query_with_timeout(
        @asq.query,
        @asq.database,
        Settings.db_statement_timeout || Settings.max_db_timeout
      )
      process_results(results)
    rescue StandardError => e
      @asq.operational_error([{
        'error_source' => 'Database',
        'error_text' => e.to_s
      }].to_json)
    end
    @asq.last_run = Time.now
    @asq.query_run_time = Time.now - start_time
    @asq.save
    # !e looks weird, but there's a test in the '.execute_query' context that
    # tests this, so I think we're good.
    perform_deliveries if !@asq.operational_error? && @should_deliver
  end

  # Deliver all associated child deliveries. This is just a shortcut to make
  # things cleaner to read.
  def perform_deliveries
    @asq.deliveries.each(&:deliver)
  end

  private

  def process_results(results)
    if @asq.query_type == 'monitor'
      process_monitor_results(results)
      return
    end
    process_report_results(results)
  end

  # The way you handle the result_hash is standardized, so let's DRY it out
  def process_monitor_results(result_array_of_hashes)
    result_array_of_hashes = result_array_of_hashes[
      0..Settings.result_limit.to_i
    ]
    Delayed::Worker.logger.debug "Processing #{@asq.name}"
    Delayed::Worker.logger.debug "Evaluating if #{@asq.alert_result_type}
                                 #{@asq.alert_operator} #{@asq.alert_value}"

    if @asq.alert_result_type == 'rows_count'
      Delayed::Worker.logger.debug "Row length: #{result_array_of_hashes.length}
        // Error value: #{@asq.alert_value.to_i}"
      process_row_count(result_array_of_hashes)
    elsif @asq.alert_result_type == 'result_value'
      # Should break if we get multiple rows back
      return unless single_row?(result_array_of_hashes)
      Delayed::Worker.logger.debug 'Result to evaluate: ' \
        "#{result_array_of_hashes[0].values[0]} " \
        "(#{result_array_of_hashes[0].values[0].class}) // \n" \
        "Error value: #{@asq.alert_value} (#{@asq.alert_value.class})"

      if invalid_non_numeric_comparison?(result_array_of_hashes[0].values[0])
        @asq.operational_error([{
          'error_source' => 'Asq',
          'error_text' => 'Error processing results: This Asq is ' \
          'using a less-than or greater-than operator against a ' \
          'non-numeric expected result. For non-numeric results, ' \
          'only the == and != operators are valid.'
        }].to_json)
      else
        compare_result_value(result_array_of_hashes)
      end
    else
      @asq.operational_error([{
        'error_source' => 'Asq',
        'error_text' => 'Error processing results: ' \
        'I tried to evaluate if this Asq was in error but I ' \
        'couldn\'t understand if I was supposed to look at the ' \
        'row count or result set.'
      }].to_json)
    end
    @asq.finish_refresh
  rescue StadardError => e
    @asq.operational_error([{
      'error_source' => 'Asq',
      'error_text' => "Error when processing results: #{e}"
    }].to_json)
  end

  def compare_result_value(result_array_of_hashes)
    result = result_array_of_hashes[0].values[0]
    alert_value = @asq.alert_value
    if result != ~/[a-zA-Z]/
      result = result.to_f
      alert_value = alert_value.to_f
    else
      result = result.to_s
      alert_value = alert_value.to_s
    end
    if result.send(@asq.alert_operator, alert_value)
      @asq.alert(result_array_of_hashes.to_json)
    else
      @asq.clear
    end
  end

  def invalid_non_numeric_comparison?(result)
    (['<', '<=', '>', '>='].include? @asq.alert_operator) &&
      @asq.alert_value =~ /[1234567890]/ && result =~ /[a-zA-Z]/
  end

  def single_row?(result_array_of_hashes)
    return true if result_array_of_hashes.length == 1
    @asq.operational_error(
      [{
        'error_source' => 'Asq', 'error_text' =>
        'Error processing results:'\
        'Expected query result with a single value.'
      }].to_json
    )
    @asq.finish_refresh
    false
  end

  def process_row_count(result_array_of_hashes)
    if result_array_of_hashes.length.send(
      @asq.alert_operator,
      @asq.alert_value.to_i
    )
      @asq.alert(result_array_of_hashes.to_json)
    else
      @asq.clear
    end
  end

  # The way you handle the result_hash is standardized, so let's DRY it out
  def process_report_results(result_array_of_hashes)
    Delayed::Worker.logger.debug "Processing #{@asq.name}"
    @asq.store_results(result_array_of_hashes.to_json)
    # if asq was previously in operational error, now's the time to clear it:
    @asq.clear
    @asq.finish_refresh
  end
end
