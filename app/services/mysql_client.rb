class MysqlClient < Client
  def self.execute_query(query_text, database, result_limit)
    # Set the port to MySQL's default if not present in the database object
    database.port ||= 3306

    # If a row limit is provded, then stick a LIMIT on the end of the query
    # unless LIMIT, COUNT or CALL are already in the query. Otheriwse, use the
    # instance variable. It's not perfect, but it helps.
    query_text = attach_result_limit(query_text, result_limit)

    begin
      client = Mysql2::Client.new(host: database.hostname,
                                  username: database.username,
                                  password: database.password,
                                  port: database.port)

      # Iterating on the items returned by calling each() on the results object
      # converts that object into an array of hashes.
      results = client.query(query_text)
      result_array_of_hashes = []
      results.each { |row| result_array_of_hashes.push(row) }

    rescue Exception => e
      raise e
    ensure
      # We have to explicitly close the client's connection. If we leave it up
      # to garbage collection, it could show up as an aborted connection in the
      # MySQL logs.
      client.close unless client.nil?
    end

    result_array_of_hashes
  end
end
