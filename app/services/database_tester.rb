class DatabaseTester
  def self.test_database(hostname, username, password, port, db_type, db_name = nil)
    database = Database.new(hostname: hostname, username: username,
                            password: password, port: port, db_type: db_type,
                            db_name: db_name)

    query_text = 'select \'pass\' as result'

    # Oracle is weird, and needs a "from dual" if you do a simple select
    query_text += ' from dual' if db_type == 'oracle'

    begin
      query_results = QueryExecutor.execute_query(query_text, database, 10)

      # The QueryExecutor returns an array of hashes. For our sample test, this
      # array of hashes could look like [{"RESULT"=>"pass"}] or
      # [{"result"=>"pass"}], depending on the database type. This means we have
      # to downcase the key of the first row of results to make sure it
      # says "result".
      if query_results[0].keys[0].downcase == 'result' &&
         query_results[0].values[0] == 'pass'
        test_results = 'Test successful!'
      else
        test_results = 'Unexpected result from a test query. This is ' \
        'probably not user error. Please have BEST investigate.'
      end
    rescue Exception => e
      test_results = "Error: #{e.to_s}"
    end

    # Dear my future self. In between bouts of crushin' fools, you may want to
    # consider having test_results return a boolean value instead of (or in
    # addition to) a standard text message. Some system in the future may want
    # the results in that format. For now, though, it's better to return text so
    # you can spend more time crushin' fools.
    test_results
  end
end
