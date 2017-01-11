require 'rails_helper'

RSpec.describe FtpService do
  let(:credentials) { 'credentials' }
  let(:directory) { 'directory' }
  let(:file_name) { 'file_name' }
  let(:string) { 'string' }
  let(:ftp_client) { double }

  before(:each) do
    allow(ftp_client).to receive(:upload_string)
    allow(ftp_client).to receive(:close)
    allow(ftp_client).to receive(:chdir)
    allow(ftp_client).to receive(:write?).and_return(true)
    allow(FtpClient).to receive(:new).and_return(ftp_client)
  end

  describe '.test' do
    it 'calls expected methods' do
      expect(ftp_client).to receive(:chdir).with(directory)
      expect(ftp_client).to receive(:close)
      FtpService.test(credentials, directory)
    end

    context 'when test succeeeds' do
      it 'returns ok hash' do
        expect(FtpService.test(credentials, directory))
          .to eq(status: 'OK', message: 'OK')
      end
    end

    context 'when write? fails' do
      it 'returns fail hash' do
        allow(ftp_client).to receive(:write?)
          .and_return(false)
        expect(FtpService.test(credentials, directory))
          .to eq(status: 'FAIL', message: 'Unable to write to directory')
      end
    end

    context 'when test fails' do
      it 'returns fail hash' do
        allow(ftp_client).to receive(:chdir)
          .and_raise(StandardError)
        expect(FtpService.test(credentials, directory))
          .to eq(status: 'FAIL', message: 'StandardError')
      end

      it 'calls close' do
        allow(ftp_client).to receive(:chdir)
          .and_raise(StandardError)
        expect(ftp_client).to receive(:close)
        FtpService.test(credentials, directory)
      end
    end
  end

  describe '.upload_string' do
    it 'calls expected methods' do
      expect(ftp_client).to receive(:chdir).with(directory)
      expect(ftp_client).to receive(:upload_string).with(string, file_name)
      expect(ftp_client).to receive(:close)
      FtpService.upload_string(credentials, directory, file_name, string)
    end

    context 'when upload fails' do
      it 'calls close' do
        allow(ftp_client).to receive(:chdir)
          .and_raise(StandardError)
        expect(ftp_client).to receive(:close)
        expect do
          FtpService.upload_string(credentials, directory, file_name, string)
        end.to raise_error(StandardError)
      end
    end
  end
end
