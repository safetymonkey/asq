# frozen_string_literal: true
require 'rails_helper'

describe 'GraphiteClient' do
  it 'initializes GraphiteAPI on init' do
    host = 'host_name'
    port = '1234'
    prefix = 'start.today'
    client = double

    expected_graphite = "#{host}:#{port}"

    expect(GraphiteAPI).to receive(:new)
      .with(graphite: expected_graphite, prefix: prefix)
      .and_return(client)
    GraphiteClient.new(host, port, prefix)
  end

  it 'initializes GraphiteAPI on init' do
    host = 'host_name'
    port = '1234'
    prefix = 'start.today'
    client = double

    expected_graphite = "#{host}:#{port}"

    expect(GraphiteAPI).to receive(:new)
      .with(graphite: expected_graphite, prefix: prefix)
      .and_return(client)
    GraphiteClient.new(host, port, prefix)
  end

  describe 'add_metric' do
    before(:each) do
      @mock_sub_client = double(GraphiteClient)

      allow(GraphiteAPI).to receive(:new)
        .and_return(@mock_sub_client)
      @client = GraphiteClient.new('host', 'port', 'prefix')
    end

    it 'passes values to graphite' do
      expected_name = 'blah'
      expected_value = 100

      expect(@mock_sub_client).to receive(:metrics)
        .with(expected_name => expected_value)

      @client.add_metric(expected_name, expected_value)
    end

    context 'when value is a string' do
      it 'throws a TypeError' do
        expected_name = 'blah'
        expected_value = 'fourteen'

        expect { @client.add_metric(expected_name, expected_value) }
          .to raise_error(TypeError)
      end
    end
  end

  describe 'valid_metric_name?' do
    context 'is valid name' do
      it 'returns true' do
        expect(GraphiteClient.valid_metric_name?('apples')).to be true
      end
    end
    context 'is chain of valid names' do
      it 'returns true' do
        expect(GraphiteClient.valid_metric_name?('how_about.apples')).to be true
      end
    end
    context 'when metric is invalid' do
      it 'returns false' do
        expect(GraphiteClient.valid_metric_name?('okay.bingo/bongo'))
          .to be false
      end
    end
  end
end
