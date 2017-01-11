require 'rails_helper'

RSpec.describe DatabaseTester do
  # hostname, username, password, port, db_type, db_name = nil
  it 'should succeed if pass is returned in result' do
    allow(QueryExecutor).to receive(:execute_query).and_return([{"RESULT"=>"pass"}])
    result = DatabaseTester.test_database('FakeHost','FakeUser','FakePassword', 433, 'postgres', 'FakeDB')
    expect(result).to eq 'Test successful!'
  end
  it 'should raise exception error'do
    allow(QueryExecutor).to receive(:execute_query).and_raise('Something broke')
    result = DatabaseTester.test_database('FakeHost','FakeUser','FakePassword', 433, 'postgres', 'FakeDB')
    expect(result).to eq('Error: Something broke')
  end
end