# Commenting everything out until we're able to break the Oracle connection into
# its own module/gem.

require 'oci8'

class OracleClient < Client
  def self.execute_query(query_text, database,
                         result_limit)
    # Oracle's version of a LIMIT statement is to wrap the whole query in
    # another query. If a row limit is provded, then wrap the query in that big
    # statement to return that number of rows unless ROWNUM, COUNT or CALL are
    # already in the query. It's not perfect, but it helps.
    query_text = attach_result_limit(query_text, result_limit)

    begin
      oci = OCI8.new(database.username, database.password, database.hostname)

      # Calling feth_hash() on the OCI8::Curosr object returned by exec()
      # returns a single row and effectively removes that row from the result
      # set. Repeat fetch_hash() until the Cursor object is nil. Doing this
      # converts the Cursor object into an array of hashes.
      results = oci.exec(query_text)
      result_array_of_hashes = []
      i = Object.new
      until i.nil?
        i = results.fetch_hash
        result_array_of_hashes.push(i) unless i.nil?
      end

    rescue Exception => e
      raise e
    ensure
      # We have to explicitly close the client's connection, If we leave it up
      # to garbage collection, it could show up as an aborted connection in the
      # Oracle logs.
      oci.logoff unless oci.nil?
    end

    result_array_of_hashes
  end

  def self.attach_result_limit(query_text, result_limit)
    if query_text.match(/ROWNUM/i) || query_text.match(/COUNT\(\*\)/i) ||
       query_text.match(/\A\s*CALL/i)
      query_text
    else
      "SELECT * FROM (#{query_text}) WHERE ROWNUM < #{result_limit}"
    end
  end
end
