require 'rails_helper'

RSpec.describe SftpService do
  let(:credentials) { 'credentials' }
  let(:directory) { 'directory' }
  let(:file_name) { 'file_name' }
  let(:string) { 'string' }
  let(:sftp_client) { double }

  before(:each) do
    allow(SftpClient).to receive(:new).and_return(sftp_client)
    allow(sftp_client).to receive(:can_write_files?).and_return(true)
    allow(sftp_client).to receive(:chdir)
    allow(sftp_client).to receive(:close)
  end

  describe '.test' do
    it 'calls expected methods' do
      expect(sftp_client).to receive(:chdir)
      expect(sftp_client).to receive(:close)
      SftpService.test(credentials, directory)
    end

    context 'when test succeeeds' do
      it 'returns ok hash' do
        expect(SftpService.test(credentials, directory))
          .to eq(status: 'OK', message: 'OK')
      end
    end

    context 'when write? fails' do
      it 'returns fail hash' do
        allow(sftp_client).to receive(:can_write_files?)
          .and_return(false)
        expect(SftpService.test(credentials, directory))
          .to eq(status: 'FAIL',
                 message: "Unable to write to remote directory: #{directory}")
      end
    end

    context 'when test fails' do
      it 'returns fail hash' do
        allow(sftp_client).to receive(:chdir)
          .and_raise(StandardError)
        expect(SftpService.test(credentials, directory))
          .to eq(status: 'FAIL', message: 'StandardError')
      end
    end

    it 'calls close' do
      allow(sftp_client).to receive(:chdir)
        .and_raise(StandardError)
      expect(sftp_client).to receive(:close)
      SftpService.test(credentials, directory)
    end
  end

  describe '.upload_string' do
    it 'calls expected methods' do
      expect(sftp_client).to receive(:chdir).with(directory)
      expect(sftp_client).to receive(:upload_string).with(string, file_name)
      expect(sftp_client).to receive(:close)
      SftpService.upload_string(credentials, directory, file_name, string)
    end

    context 'when upload fails' do
      it 'calls close' do
        allow(sftp_client).to receive(:chdir)
          .and_raise(StandardError)
        expect(sftp_client).to receive(:close)
        expect do
          SftpService.upload_string(credentials, directory, file_name, string)
        end.to raise_error(StandardError)
      end
    end
  end
end
