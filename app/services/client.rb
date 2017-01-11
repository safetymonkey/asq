# base class for the database clients.
class Client
  def execute_query
    logger.error 'Query is not intended to be called for base class Client'
  end

  def self.attach_result_limit(query_text, row_limit)
    if query_text.match(/LIMIT \d+/i) ||
       query_text.match(/COUNT\(\*\)/i) ||
       query_text.match(/\A\s*CALL/i)
      query_text
    else
      query_text + " LIMIT #{row_limit}"
    end
  end
end
