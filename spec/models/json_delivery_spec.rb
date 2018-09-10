require 'rails_helper'

RSpec.describe JsonDelivery, type: :model do
  # We create a json_delivery object before each test. "Let" is preferred
  # here because of subtle reasons - including the fact that we're creating
  # the object with just a single FactoryBot call. You can checkout the
  # Factory Girl config file to see what a FactoryBot-created
  # json_delivery object looks like.
  let(:json_delivery) { FactoryBot.create(:json_delivery) }

  it "doesn't deliver if the URL is blank" do
    json_delivery.url = ''
    json_delivery.deliver
    expect(RestClient).not_to receive(:post)
  end

  context 'if Asq is a monitor' do
    before(:each) do
      json_delivery.asq.query_type = :monitor
      json_delivery.url = Faker::Internet.url
      json_delivery.asq.deliver_on_all_clear = true
      @json_blob = { name: json_delivery.asq.name,
                     results: json_delivery.asq.result }.to_json
    end

    it 'delivers if the monitor is in alert_new' do
      json_delivery.asq.status = :alert_new
      json_delivery.asq.deliver_on_all_clear = false
      expect(RestClient).to receive(:post)
        .with(json_delivery.url, @json_blob, content_type: :json)
      json_delivery.deliver
    end

    it "doesn't deliver if the monitor is in clear_new" do
      json_delivery.asq.status = :clear_new
      expect(RestClient).not_to receive(:post)
      json_delivery.deliver
    end

    it "doesn't deliver if the monitor is in clear_still" do
      json_delivery.asq.status = :clear_still
      expect(RestClient).not_to receive(:post)
      json_delivery.deliver
    end
  end
end
