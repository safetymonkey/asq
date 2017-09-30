# frozen_string_literal:true
require 'rails_helper'

RSpec.describe GraphiteDelivery do
  let(:graphite_delivery) { FactoryGirl.create(:graphite_delivery) }

  before :each do
    graphite_delivery
  end

  it 'inits GraphiteService on delivery' do
    @mock_client = double
    expect(GraphiteClient).to receive(:new)
      .with(graphite_delivery.host,
            graphite_delivery.port,
            graphite_delivery.prefix)
      .and_return(@mock_client)
    expect(@mock_client).to receive(:add_metric)
    graphite_delivery.deliver
  end

  it 'calls GraphiteService on delivery' do
    @mock_client = double
    expect(GraphiteClient).to receive(:new)
      .with(graphite_delivery.host,
            graphite_delivery.port,
            graphite_delivery.prefix)
      .and_return(@mock_client)
    data = "[{\"met_one\":10, \"met_two\":20}]"
    graphite_delivery.asq.result = data

    expect(@mock_client).to receive(:add_metric)
      .with('met_one', 10)
    expect(@mock_client).to receive(:add_metric)
      .with('met_two', 20)
    graphite_delivery.deliver
  end

  it 'throws exception for multi rows' do
    data = "[{\"met_one\":10}, {\"met_one\":20}]"
    graphite_delivery.asq.result = data
    expect { graphite_delivery.deliver }
      .to raise_error('Graphite deliveries expect single row results')
  end

  it 'throws exception for no results' do
    data = '[]'
    graphite_delivery.asq.result = data
    expect { graphite_delivery.deliver }
      .to raise_error('Graphite deliveries expect single row results')
  end
end
