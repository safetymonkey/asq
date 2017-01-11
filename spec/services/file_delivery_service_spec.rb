require 'rails_helper'

describe 'FileDeliveryService' do
  let(:csv_string) { 'aid,campaign_id,cid\n20498,3182107,41\n4455,2518449,66\n96300,3163784,27\n4455,2518451,66\n58344,3188433,22\n58344,3188431,22\n58344,3188432,22\n58344,2679732,22\n58344,2679731,22\n58344,2679730,22\n58344,2679729,22\n58344,2679728,22\n58344,2679726,22\n58344,2679727,22\n58344,2679725,22\n58344,2679724,22\n58344,2679722,22\n58344,2679723,22\n96331,3163567,27\n96331,3163564,27\n' }
  let(:filename) { 'tester.csv' }
  let(:dirname) { '/site/' }
  # let(:mock) {}
  # let(:mockDelivery) {class_double(NetworkDeliveryService)}

  before(:each) do
    mock = double
    allow(File).to receive(:new).and_return(mock)
    allow(mock).to receive(:write)
    allow(mock).to receive(:close)
  end

  it 'checks for valid directory' do
    expect { FileDeliveryService.write_to_local_file('fakedir/', filename, csv_string) }.to raise_error(ArgumentError, 'Specified path name does not exist')
  end

  it 'joins file name and directory name' do
    expect(File).to receive(:new).with('/site/tester.csv', 'w')
    FileDeliveryService.write_to_local_file(dirname, filename, csv_string)
  end
end
