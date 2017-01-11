require 'rails_helper'

RSpec.describe DirectSftpDelivery do
  let(:sftp_delivery) { FactoryGirl.create(:direct_sftp_delivery) }
  let(:asq) { delivery.asq }

  before :each do
    sftp_delivery
  end

  it 'calls SftpService on delivery' do
    expect(SftpService).to receive(:upload_string)
    sftp_delivery.deliver
  end

  it 'calls SftpService on delivery if monitor' do
    sftp_delivery.asq.query_type = 'monitor'
    sftp_delivery.asq.status = 'alert_new'
    expect(SftpService).to receive(:upload_string)
    sftp_delivery.deliver
  end

  it 'does not call SftpService on clear delivery' do
    sftp_delivery.asq.query_type = 'monitor'
    sftp_delivery.asq.status = 'clear_new'
    sftp_delivery.asq.deliver_on_all_clear = true
    expect(SftpService).not_to receive(:upload_string)
    sftp_delivery.deliver
  end
end
