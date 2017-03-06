require 'rails_helper'

# Rails doesn't make its class methods available until after RSpec loads, so we
# need this class Database declaration to get RSpec's instance_double objects
# to work with Rails.
class Database < ActiveRecord::Base
  def submitted_at=(value)
    super
  end
end

RSpec.describe "Oracle connectivity tests", oracle_db: true do
  describe "OracleClient" do
    # These lines create mock objects for use in our tests. We don't want to use
    # actual OCI8::Client or OCI8::Cursor objects during testing, since we go
    # into this spec assuming that they work properly. Mocking the object means
    # we can directly control its output, regardless of input. We're mocking the
    # database object as well, because we're not testing that either, and we want
    # to reduce our dependencies in order to run our tests.

    let(:database) do
      instance_double('Database',
                      db_type: 'oracle',
                      hostname: 'fakehost',
                      username: 'fakeuser',
                      password: 'fakepassword',
                      port: 1521)
    end
    let(:oracle_client) { instance_double('OCI8::Client') }
    let(:oracle_cursor) { instance_double('OCI8::Cursor') }

    before(:each) do
      # This line intercepts calls to OCI8.new() and returns the mock object we
      # defined earlier.
      allow(OCI8).to receive(:new).and_return(oracle_client)

      # Using mocks object in place of actual OCI8 objects means we can stub their
      # care about. We don't actually want to connect to a database, run a query,
      # and iterate through those results, because we're not testing that. We're
      # testing what our OracleClient object does with the results *from* that
      # query. So we have our mock object return results that act the same as the
      # actual OCI8::Cursor result object.
      allow(oracle_client).to receive(:exec).and_return(oracle_cursor)
      allow(oracle_client).to receive(:logoff)
      allow(oracle_cursor).to receive(:fetch_hash).and_return({ 'name' => 'frank' },
                                                              { 'age' => 72 },
                                                              nil)
    end

    it 'takes a query and returns an array of hashes' do
      # We're passing a fake query into execute_query. Thanks to the mocked
      # OCI8::Client object, the results from our fake object are always going to
      #  be the same.
      results = OracleClient.execute_query('fake query', database, 10)

      # This is the actual test. If execute_query() can't translate the results
      # from an OCI8::Cursor object into an array of hashes, then something is
      # broken.
      expect(results).to eq([{ 'name' => 'frank' }, { 'age' => 72 }])
    end

    it 'adds a row limiter to the passed-in query text based on a provided row_limit' do
      # We're passing fake query text here to make it clear that we're testing to
      # see if execute_query() properly encapuslates the query in Oracle's version
      # of the LIMIT statement.
      query_text = 'fake query'
      expect(oracle_client).to receive(:exec).with("SELECT * FROM (#{query_text}) WHERE ROWNUM < 1000")
      OracleClient.execute_query(query_text, database, 1000)
    end

    it 'does not add a row limiter to the passed-in query text if it contains the word LIMIT' do
      # We're passing fake query text here to make it clear that we're testing to
      # see if OracleClient.execute_query() detects that the query already does
      # the Oracle encapsualtion thing that it does in place of the LIMIT
      # statement. If so, then execute_query() bypasses adding that encapsulation
      # to the query text.
      query_text = "SELECT * FROM ('fake query') WHERE ROWNUM < 1000"
      expect(oracle_client).to receive(:exec).with(query_text)
      OracleClient.execute_query(query_text, database, 500)
    end

    it 'does not add a row limiter to the passed-in query text if it contains the word CALL' do
      # We're passing fake query text here to make it clear that we're testing to
      # see if OracleClient.execute_query() detects that CALL is in the query. If
      # so, then execute_query() bypasses adding the Oracle LIMIT-style
      # encapsulation to the query text.
      query_text = 'CALL fake_stored_proc'
      expect(oracle_client).to receive(:exec).with(query_text)
      OracleClient.execute_query(query_text, database, 500)
    end

    it 'does not add a row limiter to the passed-in query text if it contains the word COUNT(*)' do
      # We're passing fake query text here to make it clear that we're testing to
      # see if OracleClient.execute_query() detects that COUNT (*) is in the
      # query. If so, then execute_query() bypasses adding the Oracle LIMIT-style
      # encapsulation to the query text.
      query_text = 'select COUNT(*) from fake_table'
      expect(oracle_client).to receive(:exec).with(query_text)
      OracleClient.execute_query(query_text, database, 500)
    end
  end
end
