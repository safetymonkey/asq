require 'rails_helper'

RSpec.describe QueryExecutor do
  let (:query_text) { "fake query" }

  # Each of these tests do the same thing. They each create a mock Database object, and pass that object into the Query Executor
  # to see what comes out. We use mock objects because we aren't really making a database connection, and we don't want to rely
  # on the Database object actually needing to work in order for our tests to pass. Save that for integration tests.

  it "executes MysqlClient.execute_query() in response to a passed-in MySQL database object", 'oracle_db' => true do
    database = instance_double("Database", :db_type => "mysql", :hostname => "fakehost", :username => "fakeuser", :password => "fakepassword",:port => 3306)
    expect(MysqlClient).to receive(:execute_query)
    QueryExecutor.execute_query(query_text, database, 10)
  end

  it "executes Postgres.execute_query() in response to a passed-in MySQL database object", 'postgres_db' => true  do
    database = instance_double("Database", :db_type => "postgres", :hostname => "fakehost", :username => "fakeuser", :password => "fakepassword",:port => 5432, :db_name => "fakedb" )
    expect(PostgresClient).to receive(:execute_query)
    QueryExecutor.execute_query(query_text, database, 10)
  end

  it "executes Oracle.execute_query() in response to a passed-in MySQL database object", 'mysql_db' => true do
    database = instance_double("Database", :db_type => "oracle", :hostname => "fakehost", :username => "fakeuser", :password => "fakepassword",:port => 1521)
    expect(OracleClient).to receive(:execute_query)
    QueryExecutor.execute_query(query_text, database, 10)
  end

  describe 'execute_query_with_timeout' do
    it 'calls execute_query' do
      mock_setting(:result_limit, 50000)
      expect(QueryExecutor).to receive(:execute_query).with('q', 'db', 50000).and_return('complete')
      QueryExecutor.execute_query_with_timeout('q', 'db', 10)
    end

    it "calls thread.join with correct timeout" do
      thr = Thread.new { 'complete' }
      allow(Thread).to receive(:new).and_return(thr)
      expect(thr).to receive(:join).with(60).and_call_original
      QueryExecutor.execute_query_with_timeout('q', 'db', 60)
    end

    context 'when thread completes' do
      it "returns thread.value" do
        thr = Thread.new { 'complete' }
        allow(Thread).to receive(:new).and_return(thr)
        expect(QueryExecutor.execute_query_with_timeout('q','db', 60)).to eq('complete')
      end
    end

    context 'when times out' do
      it "returns error if thread doesn't complete" do
        thr = Thread.new { 'complete' }
        allow(thr).to receive(:join).and_return(nil)
        allow(Thread).to receive(:new).and_return(thr)
        expect{ QueryExecutor.execute_query_with_timeout('q', 'db', 60) }.to raise_error(RuntimeError)
      end
    end
  end
  describe 'result limit' do
    it 'pass result limit to postres client', 'postgres_db' => true do
      database = instance_double("Database", :db_type => "postgres", :hostname => "fakehost", :username => "fakeuser", :password => "fakepassword",:port => 1521)
      expect(PostgresClient).to receive(:execute_query).with('select 1', database, 50000)
      QueryExecutor.execute_query('select 1', database, 50000)
    end
    it 'pass result limit to mysql client', 'mysql_db' => true do
      database = instance_double("Database", :db_type => "mysql", :hostname => "fakehost", :username => "fakeuser", :password => "fakepassword",:port => 1521)
      expect(MysqlClient).to receive(:execute_query).with('select 1', database, 50000)
      QueryExecutor.execute_query('select 1', database, 50000)
    end
    it 'pass result limit to oracle client', 'oracle_db' => true do
      database = instance_double("Database", :db_type => "oracle", :hostname => "fakehost", :username => "fakeuser", :password => "fakepassword",:port => 1521)
      expect(OracleClient).to receive(:execute_query).with('select 1', database, 50000)
      QueryExecutor.execute_query('select 1', database, 50000)
    end
  end
end
