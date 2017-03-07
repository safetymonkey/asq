require 'rails_helper'

# Rails doesn't make its class methods available until after RSpec loads, so we
# need this class Database declaration to get RSpec's instance_double objects to
# work with Rails.
class Database < ActiveRecord::Base
  def submitted_at=(value)
    super
  end
end

RSpec.describe 'MysqlClient', 'mysql_db' => true do
  # These lines create mock objects for use in our tests. We don't want to use
  # an actual MySQL::Client object during testing, since we go into this spec
  # assuming that it works properly. Mocking the object means we can directly
  # control its output, regardless of input. We're mocking the database object
  # as well, because we're not testing that either, and we want to reduce our
  # dependencies in order to run our tests.
  let(:database) do
    instance_double('Database',
                    db_type: 'mysql',
                    hostname: 'fakehost',
                    username: 'fakeuser',
                    password: 'fakepassword',
                    port: 3306)
  end
  let(:mysql2_client) { instance_double('Mysql2::Client') }

  before(:each) do
    # This line intercepts calls to Mysql2::Client.new and returns the mock
    # object we defined earlier.
    allow(Mysql2::Client).to receive(:new).and_return(mysql2_client)

    # Using a mock object in place of a MySQL2::Client object means we can stub
    # its query() method. We don't actually want to connect to a database
    # and run a query, because we're not testing that. We're testing what our
    # MysqlClient object does with the results *from* that query.
    allow(mysql2_client).to receive(:query).and_return([{ 'name' => 'frank' },
                                                        { 'age' => 72 }])
    allow(mysql2_client).to receive(:close)
  end

  it 'takes a query and returns an array of hashes' do
    # We're passing a fake query into execute_query. Thanks to the mocked
    # Mysql2::Client object, the results from Mysql2::Client are always going
    # to be the same.
    results = MysqlClient.execute_query('fake query', database, 10)

    # This is the actual test. If execute_query() can't translate the results
    # from a Mysql2::Results object into a Ruby array of hashes, then
    # something is broken.
    expect(results).to eq([{ 'name' => 'frank' }, { 'age' => 72 }])
  end

  it 'adds a row limiter to the passed-in query text based on a provided row_limit' do
    # We're passing fake query text here to make it clear that we're testing
    # to see if execute_query() simply adds "LIMIT 1000" to the end of it.
    query_text = 'fake query'
    expect(mysql2_client).to receive(:query).with(query_text + ' LIMIT 1000')
    MysqlClient.execute_query(query_text, database, 1000)
  end

  it 'does not add a row limiter to the passed-in query text if it contains the word LIMIT' do
    # We're passing fake query text here to make it clear that we're testing
    # to see if MysqlClient.execute_query() detects that LIMIT is already in
    # the query. If so, then execute_query() bypasses adding LIMIT 500 to
    # the end of the query text.
    query_text = 'fake query LIMIT 1000'
    expect(mysql2_client).to receive(:query).with(query_text)
    MysqlClient.execute_query(query_text, database, 500)
  end

  it 'does not add a row limiter to the passed-in query text if it contains the word CALL' do
    # We're passing fake query text here to make it clear that we're testing
    # to see if MysqlClient.execute_query() detects that CALL is in the query.
    # If so, then execute_query() bypasses adding LIMIT 500 to the end of
    # the query text.
    query_text = 'CALL fake_stored_proc'
    expect(mysql2_client).to receive(:query).with(query_text)
    MysqlClient.execute_query(query_text, database, 500)
  end

  it 'does not add a row limiter to the passed-in query text if it contains the word COUNT(*)' do
    # We're passing fake query text here to make it clear that we're testing
    #  to see if MysqlClient.execute_query() detects that COUNT (*) is in the
    # query. If so,  then execute_query() bypasses adding LIMIT 500 to the end
    # of the query text.
    query_text = 'select COUNT(*) from fake_table'
    expect(mysql2_client).to receive(:query).with(query_text)
    MysqlClient.execute_query(query_text, database, 500)
  end
end
