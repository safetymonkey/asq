require 'rails_helper'

RSpec.describe AutosftpDelivery, type: :model do
  let(:autosftp_delivery) { FactoryGirl.build(:autosftp_delivery) }
  let(:asq) { autosftp_delivery.asq }

  it 'does not call FileDeliverService.write_to_local_file with no prefix' do
    autosftp_delivery.prefix = ''
    expect(FileDeliveryService).not_to receive(:write_to_local_file)
    autosftp_delivery.deliver
  end

  it 'passes expected values to FileDeliveryService' do
    autosftp_delivery.prefix = 'test'
    allow(Settings).to receive(:method_missing).and_return('path/to/files')
    allow(asq).to receive(:to_csv).and_return('csv_data')
    allow(asq).to receive(:get_processed_filename).and_return('filename.csv')
    expect(FileDeliveryService).to receive(:write_to_local_file).with('path/to/files', 'test.filename.csv', 'csv_data')
    autosftp_delivery.deliver
  end
end
