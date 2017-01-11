require 'rails_helper'

RSpec.describe FtpClient do
  let(:credentials) do
    { host: 'host', port: 'port', username: 'user', password: 'pw',
      directory: '/dir' }
  end
  let(:directory) { '/dir' }
  let(:data) { 'data string' }
  let(:ftp_client) { double }
  let(:file_name) { 'test.txt' }
  let(:client) { FtpClient.new(credentials) }

  before(:each) do
    allow(ftp_client).to receive(:debug_mode=)
    allow(ftp_client).to receive(:passive=)
    allow(ftp_client).to receive(:connect)
    allow(ftp_client).to receive(:close)
    allow(ftp_client).to receive(:chdir)
    allow(ftp_client).to receive(:puttextcontent)
    allow(ftp_client).to receive(:nlst).and_return('')
    allow(ftp_client).to receive(:delete)
    allow(ftp_client).to receive(:login).and_return(true)
    allow(Net::FTP).to receive(:new).and_return(ftp_client)
  end

  describe '.initialize' do
    it 'initializes connection' do
      expect(ftp_client).to receive(:connect).with('host', 'port')
      expect(ftp_client).to receive(:login).with('user', 'pw')
      FtpClient.new(credentials)
    end

    context 'when Net::FTPPermError is returned' do
      it 'raises error' do
        allow(ftp_client).to receive(:login).and_raise(Net::FTPPermError)
        expect { FtpClient.new(credentials) }.to raise_error(StandardError)
      end
    end

    context 'when hostname is blank' do
      it 'raises error' do
        credentials[:host] = ''
        expect { FtpClient.new(credentials) }.to raise_error(StandardError)
      end
    end

    context 'when protocol is included with hostname' do
      it 'strips host name' do
        credentials[:host] = 'ftp://host'
        expect(ftp_client).to receive(:connect).with('host', 'port')
        FtpClient.new(credentials)
      end
    end

    context 'when port is blank' do
      it 'assigns port 21' do
        credentials[:port] = '21'
        expect(ftp_client).to receive(:connect).with('host', '21')
        FtpClient.new(credentials)
      end
    end
  end

  describe '.chdir' do
    it 'calls chdir' do
      expect(ftp_client).to receive(:chdir).with(directory)
      client.chdir(directory)
    end

    context 'when directory is blank' do
      it 'does not call chdir' do
        directory = ''
        expect(ftp_client).not_to receive(:chdir).with(directory)
        client.chdir(directory)
      end
    end
  end

  describe '.upload_string' do
    it 'calls puttextcontent' do
      expect(ftp_client).to receive(:puttextcontent).with(data, file_name)
      client.upload_string(data, file_name)
    end

    context 'when file_name is blank' do
      it 'raises error' do
        file_name = ''
        expect { client.upload_string(data, file_name) }
          .to raise_error(StandardError)
      end
    end

    context 'when returns FTPPermError' do
      it 'raises error' do
        allow(ftp_client).to receive(:puttextcontent)
          .and_raise(Net::FTPPermError)
        expect { client.upload_string(data, file_name) }
          .to raise_error(StandardError)
      end
    end
  end

  describe '.close' do
    it 'calls close' do
      expect(ftp_client).to receive(:close)
      client.close
    end
  end

  describe '.write?' do
    context 'put and delete succeed' do
      it 'returns true' do
        expect(client.write?).to be_truthy
      end

      it 'calls puttextcontent' do
        expect(ftp_client).to receive(:puttextcontent)
        client.write?
      end

      it 'calls nlst' do
        expect(ftp_client).to receive(:nlst)
        client.write?
      end

      it 'calls delete' do
        expect(ftp_client).to receive(:delete)
        client.write?
      end
    end

    context 'cant generate unique filename for test' do
      it 'raises exception' do
        allow(ftp_client).to receive(:nlst).and_return('X')
        expect { client.write? }.to raise_error(StandardError)
      end
    end

    context 'put fails' do
      it 'returns false' do
        allow(ftp_client).to receive(:puttextcontent)
          .and_raise(Net::FTPPermError)
        expect(client.write?).to be_falsey
      end
    end
  end
end
