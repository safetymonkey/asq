# frozen_string_literal: true
require 'rails_helper'

describe 'GraphiteClient' do
  it 'builds' do
    host = 'host_name'
    port = '1234'
    client = GraphiteClient.new(host, port)
    expect(client.host).to be(host)
    expect(client.port).to be(port)
  end
end
