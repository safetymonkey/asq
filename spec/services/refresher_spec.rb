require 'rails_helper'

RSpec.describe Refresher, type: :service do

  it 'instance method .refresh properly called with class method' do
    asq_report = FactoryGirl.create(:asq, query_type: :report)
    refresher = double
    allow(Refresher).to receive(:new).and_return(refresher)
    expect(refresher).to receive(:refresh)
    Refresher.refresh(asq_report.id, true)

  end

  before (:each) do
    Delayed::Worker.delay_jobs = false
  end
  
  describe '.refresh' do
    context 'when delivery = true' do
      it 'calls perform_deliveries' do
        asq_report = FactoryGirl.create(:asq, query_type: :report)
        refresher = Refresher.new(asq_report.id, true)
        allow(QueryExecutor).to receive(:execute_query_with_timeout)
        allow(refresher).to receive(:process_report_results)
        expect(refresher).to receive(:perform_deliveries)
        refresher.refresh
      end

      context 'on exception' do
        it 'does not call perform_deliveries' do
          asq_report = FactoryGirl.create(:asq, query_type: :report)
          refresher = Refresher.new(asq_report.id, true)
          allow(QueryExecutor).to receive(:execute_query).and_raise('fail')
          allow(refresher).to receive(:process_report_results)
          expect(refresher).not_to receive(:perform_deliveries)
          refresher.refresh
        end
        it 'raises operational error' do
          asq_report = FactoryGirl.create(:asq, query_type: :report)
          refresher = Refresher.new(asq_report.id, true)
          allow(QueryExecutor).to receive(:execute_query).and_raise('fail')
          expect(refresher.instance_variable_get(:@asq)).to receive(:operational_error)
          refresher.refresh
        end
      end
    end

    context 'when delivery is not passed' do
      it 'does not call perform_deliveries' do
        asq_report = FactoryGirl.create(:asq, query_type: :report)
        refresher = Refresher.new(asq_report.id)
        allow(QueryExecutor).to receive(:execute_query)
        allow(refresher).to receive(:process_report_results)
        expect(refresher).not_to receive(:perform_deliveries)
        refresher.refresh
      end
    end
  end

  describe 'perform_deliveries' do
    context 'when query_type = monitor' do
      it 'calls deliver on each delivery' do
        asq_no_file_options = FactoryGirl.create(:asq, query_type: :monitor)
        refresher = Refresher.new(asq_no_file_options.id)
        delivery = double
        allow(refresher.instance_variable_get(:@asq)).to receive(:deliveries)
                                          .and_return([delivery, delivery, delivery])
        expect(delivery).to receive(:deliver).exactly(3).times
        refresher.perform_deliveries
      end
    end

    context 'when query_type = report' do
      it 'calls deliver on deliveries' do
        asq_report = FactoryGirl.create(:asq, query_type: :report)
        refresher = Refresher.new(asq_report.id)
        delivery = double
        allow(refresher.instance_variable_get(:@asq)).to receive(:deliveries)
                                 .and_return([delivery, delivery, delivery])
        expect(delivery).to receive(:deliver).exactly(3).times
        refresher.perform_deliveries
      end
    end
  end

  describe 'processing results' do
    context 'when asq.query_type is  monitor' do
      context 'has invalid result type' do
        it 'should return operational error' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '>', alert_value: '0',
                                          alert_result_type: '')


          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'PULLED_ON' => '2016-05-02', 'COUNT(*)' => '6.0' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:operational_error)
          refresher.refresh
        end
      end
      context 'when #alert_operator is row count' do
        it 'calls asq.alert' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '>', alert_value: '0',
                                          alert_result_type: 'rows_count')

          
          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'PULLED_ON' => '2016-05-02', 'COUNT(*)' => '6.0' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:alert)
          refresher.refresh
        end

        it 'calls asq.clear' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '>', alert_value: '1',
                                          alert_result_type: 'rows_count')
          
          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'PULLED_ON' => '2016-05-02', 'COUNT(*)' => '6.0' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:clear)
          refresher.refresh
        end
      end
      context 'when alert_operator is result_value' do
        it 'can compare two strings' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '==', alert_value: 'peace',
                                          alert_result_type: 'result_value')

          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'COUNT(*)' => 'peace' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:alert)
          refresher.refresh
        end
        it 'sets operational error when non_numeric value is being comparing greater then or less to a numerical value' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '>', alert_value: 1,
                                          alert_result_type: 'result_value')

          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'COUNT(*)' => 'peace' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:operational_error)
          refresher.refresh
        end
        it 'alerts when value meets threshold' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '==', alert_value: '1',
                                          alert_result_type: 'result_value')

          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'COUNT(*)' => '1' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:alert)
          refresher.refresh
        end
        it 'sends asq.clear if results do not meet alert value' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '==', alert_value: '2',
                                          alert_result_type: 'result_value')

          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'COUNT(*)' => '1' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:clear)
          refresher.refresh
        end
        it 'sends asq.operational_error when results are more than one row' do
          asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                          alert_operator: '==', alert_value: '2',
                                          alert_result_type: 'result_value')

          refresher = Refresher.new(asq_monitor.id)
          allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                      .and_return([{ 'COUNT(*)' => '1' }, { 'sum(*)' => '1' }])
          expect(refresher.instance_variable_get(:@asq)).to receive(:operational_error)
          refresher.refresh
        end
      end
    end
    context 'when Asq.query_type is report' do
      it 'should store asq results' do
        asq_monitor =FactoryGirl.create(:asq, query_type: :report)

        refresher = Refresher.new(asq_monitor.id)
        allow(QueryExecutor).to receive(:execute_query_with_timeout)
                                    .and_return([{ 'COUNT(*)' => '1' }, { 'sum(*)' => '1' }])
        expect(refresher.instance_variable_get(:@asq)).to receive(:store_results)
        expect(refresher.instance_variable_get(:@asq)).to receive(:clear)
        expect(refresher.instance_variable_get(:@asq)).to receive(:finish_refresh)
        refresher.refresh
      end
    end
    context 'deliveries for asq' do
      it 'should call deliveries when not in operational error state and should deliver is true' do
        asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                        alert_operator: '>', alert_value: '0',
                                        alert_result_type: 'rows_count',
                                        status: 'alert_new')
        refresher = Refresher.new(asq_monitor.id,true)
        delivery = double
        allow(QueryExecutor).to receive(:execute_query_with_timeout).and_return('')
        allow(refresher.instance_variable_get(:@asq)).to receive(:deliveries)
                                                             .and_return([delivery, delivery, delivery])
        expect(delivery).to receive(:deliver).exactly(3).times
        refresher.refresh
      end
      it 'should not call deliveries when in operational error state' do
        asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                        alert_operator: '>', alert_value: '0',
                                        alert_result_type: 'rows_count',
                                        status: 'operational_error')
        refresher = Refresher.new(asq_monitor.id,true)
        delivery = double
        allow(refresher.instance_variable_get(:@asq)).to receive(:deliveries)
                                                             .and_return([delivery, delivery, delivery])
        expect(delivery).to_not receive(:deliver)
        refresher.refresh
      end
      it 'should not call deliveries when should_deliver is false' do
        asq_monitor =FactoryGirl.create(:asq, query_type: :monitor,
                                        alert_operator: '>', alert_value: '0',
                                        alert_result_type: 'rows_count',
                                        status: 'operational_error')
        refresher = Refresher.new(asq_monitor.id)
        delivery = double
        allow(refresher.instance_variable_get(:@asq)).to receive(:deliveries)
                                                             .and_return([delivery, delivery, delivery])
        expect(delivery).to_not receive(:deliver)
        refresher.refresh
      end
    end
  end
end