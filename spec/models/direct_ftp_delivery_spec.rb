require 'rails_helper'

RSpec.describe DirectFtpDelivery do
  let(:ftp_delivery) { FactoryBot.create(:direct_ftp_delivery) }

  before :each do
    ftp_delivery
  end

  it 'calls FtpService on delivery' do
    expect(FtpService).to receive(:upload_string)
    ftp_delivery.deliver
  end

  it 'calls FtpService on delivery if monitor' do
    ftp_delivery.asq.query_type = 'monitor'
    ftp_delivery.asq.status = 'alert_new'
    expect(FtpService).to receive(:upload_string)
    ftp_delivery.deliver
  end

  it 'does not call FtpService on clear delivery' do
    ftp_delivery.asq.query_type = 'monitor'
    ftp_delivery.asq.status = 'clear_new'
    ftp_delivery.asq.deliver_on_all_clear = true
    expect(FtpService).not_to receive(:upload_string)
    ftp_delivery.deliver
  end
end
