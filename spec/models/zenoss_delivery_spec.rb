require 'rails_helper'

RSpec.describe ZenossDelivery, type: :model do
  let(:delivery) { FactoryBot.create(:zenoss_delivery) }
  before(:example) do
    mock_setting(:zenoss_enabled, true)
    mock_setting(:zenoss_url, 'www.blah.com')
    delivery.asq.status = 'alert_new'
  end

  context 'while url is blank' do
    it 'does not deliver' do
      mock_setting(:zenoss_url, '')

      expect(ZenossService).not_to receive(:post)
      delivery.deliver
    end
  end
  context 'When Asq status = alert_new' do
    it 'delivers' do
      delivery.asq.status = 'alert_new'
      expect(ZenossService).to receive(:post).with(delivery.asq)
      delivery.deliver
    end
  end
  context 'when Asq status = Clear_new' do
    it 'delivers' do
      delivery.asq.status = 'clear_new'
      expect(ZenossService).to receive(:post).with(delivery.asq)
      delivery.deliver
    end
  end
  context 'When asq is in a still state' do
    it 'does deliver on alert still' do
      delivery.asq.status = 'alert_still'

      expect(ZenossService).to receive(:post)
      delivery.deliver
    end
    it 'does not deliver on clear still' do
      delivery.asq.status = 'clear_still'

      expect(ZenossService).not_to receive(:post)
      delivery.deliver
    end
  end
  it 'does not deliver for reports' do
    delivery.asq.query_type = 'report'

    expect(ZenossService).not_to receive(:post)
    delivery.deliver
  end
  it 'destroys on save when not enabled' do
    delivery.enabled = false

    expect(delivery).to receive(:destroy)
    delivery.save
  end
  context 'while settings.zenoss_enabed is true' do
    it 'delivers' do
      delivery.asq.status = 'alert_new'

      expect(ZenossService).to receive(:post)
      delivery.deliver
    end
  end
  context 'while settings.zenoss_enabled is false' do
    it 'does not deliver' do
      delivery.asq.status = 'alert_new'
      mock_setting(:zenoss_enabled, false)

      expect(ZenossService).not_to receive(:post)
      delivery.deliver
    end
  end

  context 'when delivery fails' do
    it 'logs the failure' do
      allow(ZenossService).to receive(:post).and_raise(StandardError)
      allow(Settings).to receive(:method_missing).and_return(Faker::Lorem)
      logger = double
      allow(Delayed::Worker).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      expect(logger).to receive(:debug)
      delivery.deliver
    end
  end
end
