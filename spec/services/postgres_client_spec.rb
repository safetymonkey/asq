require 'rails_helper'

# Rails doesn't make its class methods available until after RSpec loads, so we
# need this class Database declaration to get RSpec's instance_double objects to
# work with Rails.
class Database < ActiveRecord::Base
  def submitted_at=(value)
    super
  end
end

RSpec.describe 'PostgresClient', 'postges_db' => true do
  let(:database) do
    instance_double('Database',
                    db_type: 'postgres',
                    hostname: 'fakehost',
                    username: 'fakeuser',
                    password: 'fakepassword',
                    port: 5432,
                    db_name: 'fakedb')
  end
  let(:postgres_client) { instance_double('PG::Connection') }
  before(:each) do
    # This line creates a mock PG:Connection object for use in each test. It
    # needs to be an instance variable, otherwise the mock object is cleared out
    # after each test. We don't want to use an actual PG:Connection object
    #  during testing, since we go into this spec assuming that Client object
    #  works properly. Mocking the object means we can directly control its
    # output, regardless of input.
    allow(PG::Connection).to receive(:new).and_return(postgres_client)

    # Using a mock object in place of a PG:Connection object means we can stub
    # its exec_params() method. We don't actually want to connect to a database
    # and run a query, because we're not testing that. We're testing what our
    # PostgresClient object does with the *results* from that query.
    allow(postgres_client).to receive(:exec_params).and_return([{ 'name' => 'frank' },
                                                                { 'age' => 72 }])
    allow(postgres_client).to receive(:close)
  end

  it 'takes a query and returns an array of hashes' do
    # We're passing a fake query into execute_query. Thanks to the mocked
    # PG:Connection object, the results from PG:Connection are always going to
    # be the same.
    results = PostgresClient.execute_query('fake query', database, 10)

    # This is the actual test. If execute_query() can't translate the results
    # from a PG::Results object into a Ruby array of hashes, then
    # something is broken.
    expect(results).to eq([{ 'name' => 'frank' }, { 'age' => 72 }])
  end

  it 'adds a row limiter to the passed-in query text based on a provided row_limit' do
    # We're passing fake query text here to make it clear that we're testing to
    # see if execute_query() simply adds "LIMIT 1000" to the end of it.
    query_text = 'fake query'
    expect(postgres_client).to receive(:exec_params).with(query_text + ' LIMIT 1000')
    PostgresClient.execute_query(query_text, database, 1000)
  end

  it 'does not add a row limiter to the passed-in query text if it contains the word LIMIT' do
    # We're passing fake query text here to make it clear that we're testing to
    # see if PostgresClient.execute_query() detects that LIMIT is already in the
    # query. If so, then execute_query() bypasses adding LIMIT 500 to the end of
    # the query text.
    query_text = 'fake query LIMIT 1000'
    expect(postgres_client).to receive(:exec_params).with(query_text)
    PostgresClient.execute_query(query_text, database, 500)
  end

  it 'does not add a row limiter to the passed-in query text if it contains the word CALL' do
    # We're passing fake query text here to make it clear that we're testing to
    # see if PostgresClient.execute_query() detects that CALL is in the query.
    # If so, then execute_query() bypasses adding LIMIT 500 to the end of the
    # query text.
    query_text = 'CALL fake_stored_proc'
    expect(postgres_client).to receive(:exec_params).with(query_text)
    PostgresClient.execute_query(query_text, database, 500)
  end

  it 'does not add a row limiter to the passed-in query text if it contains the word COUNT(*)' do
    # We're passing fake query text here to make it clear that we're testing to
    # see if PostgresClient.execute_query() detects that COUNT (*) is in the
    # query. If so, then execute_query() bypasses adding LIMIT 500 to the end of
    # the query text.
    query_text = 'select COUNT(*) from fake_table'
    expect(postgres_client).to receive(:exec_params).with(query_text)
    PostgresClient.execute_query(query_text, database, 500)
  end
end
