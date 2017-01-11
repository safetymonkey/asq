class QueryExecutor
  # This class is pretty simple. Take in some query text, a database object and
  # an optional row limit, and execute the query against the database type
  # contained in the database object.
  def self.execute_query(query_text, database, result_limit)
    case database.db_type
    when 'mysql'
      MysqlClient.execute_query(query_text, database, result_limit)
    when 'postgres'
      PostgresClient.execute_query(query_text, database, result_limit)
    when 'oracle'
      OracleClient.execute_query(query_text, database, result_limit)
    else
      abort 'Something has gone horribly wrong. Invalid database type.'
    end
  end

  def self.execute_query_with_timeout(query_text, database, timeout)
    result_limit = Settings.result_limit
    thr = Thread.new do
      thr_results = execute_query(query_text, database, result_limit)
      ActiveRecord::Base.clear_active_connections!
      thr_results
    end
    result = thr.join(timeout.to_i)
    thr.exit
    ActiveRecord::Base.clear_active_connections!
    return result.value if result
    thr.exit
    fail 'Query Timeout'
  end
end
