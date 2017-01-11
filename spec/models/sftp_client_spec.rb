require 'rails_helper'

RSpec.describe SftpClient do
  let(:credentials) do
    { host: 'host', username: 'user', password: 'pw', port: 'port' }
  end

  let(:directory) { '/dir' }
  let(:data) { 'data string' }
  let(:file_name) { 'test.txt' }
  let(:sftp_client_gem) { double }
  let(:client) { SftpClient.new(credentials) }

  before(:each) do
    allow(FunSftp::SFTPClient).to receive(:new).and_return(sftp_client_gem)
  end

  describe '.initialize' do
    it 'attempts to connect' do
      expect(FunSftp::SFTPClient).to receive(:new)
        .with('host', 'user', 'pw',
              password: 'pw',
              port: 'port',
              number_of_password_prompts: 0,
              keys: ['config/keys/id_rsa'],
              host_key: 'ssh-rsa',
              timeout: 120)
      SftpClient.new(credentials)
    end

    context 'when a SocketError is returned' do
      it 'raises a StandardError' do
        allow(FunSftp::SFTPClient).to receive(:new).and_raise(SocketError)
        expect { SftpClient.new(credentials) }.to raise_error(StandardError)
      end
    end

    context 'when the hostname is blank' do
      it 'raises an error' do
        credentials[:host] = ''
        expect { SftpClient.new(credentials) }.to raise_error(StandardError)
      end
    end

    context 'when a protocol is included with hostname' do
      it 'strips the protocol from the hostname' do
        credentials[:host] = 'sftp://host'
        expect(FunSftp::SFTPClient).to receive(:new)
          .with('host', any_args)
        SftpClient.new(credentials)
      end
    end

    context 'when the provided port is blank' do
      it 'defaults to port 22' do
        credentials[:port] = ''
        expect(FunSftp::SFTPClient).to receive(:new)
          .with(any_args, hash_including(port: '22'))
        SftpClient.new(credentials)
      end
    end
  end

  describe '.chdir' do
    it 'calls FunSftp.SFTPClient.chdir' do
      expect(sftp_client_gem).to receive(:chdir).with(directory)
      client.chdir(directory)
    end

    context 'when directory is blank' do
      it 'does not call FunSftp.SFTPClient.chdir' do
        directory = ''
        expect(sftp_client_gem).not_to receive(:chdir).with(directory)
        client.chdir(directory)
      end
    end
  end

  describe '.can_write_files?' do
    before(:each) do
      file_name = Faker::Lorem.characters(8)
      allow(SecureRandom).to receive(:hex).and_return(file_name)
      allow(sftp_client_gem).to receive(:upload!)
      allow(sftp_client_gem).to receive(:rm)
      # file_exists? is called twice during the can_write_files? method.
      # The file_exists? method calls SFTPClient.size twice - once to
      # see if the file is there before writing it, and once after. The
      # first time it's called, an exception needs to be thrown. The
      # second time, it needs to return a non-zero number.
      size_method_called = false
      file_size = Faker::Number
      allow(sftp_client_gem).to receive(:size) {
        if size_method_called
          file_size
        else
          size_method_called = true
          raise(Net::SFTP::StatusException)
        end
      }
    end

    it 'attempts to write a test file' do
      expect(client).to receive(:upload_string)
      client.can_write_files?
    end

    it 'attempts to delete the test file' do
      expect(sftp_client_gem).to receive(:rm)
      client.can_write_files?
    end

    it 'handles not being able to delete the test file' do
      allow(sftp_client_gem).to receive(:rm)
        .and_raise(Net::SFTP::StatusException)
      logger = double
      allow(logger).to receive(:debug)
      allow(Delayed::Worker).to receive(:logger).and_return(logger)
      expect(logger).to receive(:debug)
      client.can_write_files?
    end
  end

  describe '.upload_string' do
    it 'calls FunSftp.SFTPClient.upload!' do
      io = double
      allow(StringIO).to receive(:new).and_return(io)
      allow(client).to receive(:file_exists?).and_return(true)
      expect(sftp_client_gem).to receive(:upload!).with(io, file_name)
      client.upload_string(data, file_name)
    end

    context 'when file_name is blank' do
      it 'raises an error' do
        file_name = ''
        expect { client.upload_string(data, file_name) }
          .to raise_error(StandardError)
      end
    end

    context 'when upload fails' do
      it 'succeeds after two retries' do
        failures_remaining = 2
        allow(client).to receive(:file_exists?).and_return(true)
        allow(sftp_client_gem).to receive(:upload!) {
          failures_remaining -= 1
          raise StandardError if failures_remaining > 0
        }
        expect { client.upload_string(data, file_name) }
          .not_to raise_error
      end

      it 'raises an error after reaching max retries' do
        allow(sftp_client_gem).to receive(:upload!).and_raise(StandardError)
        expect { client.upload_string(data, file_name) }
          .to raise_error(StandardError)
      end
    end
  end

  describe '.close' do
    it 'calls sftp_client_gem.close' do
      expect(sftp_client_gem).to receive(:close)
      client.close
    end

    context 'when it has problems closing' do
      it 'rescues and logs the raised exception' do
        allow(sftp_client_gem).to receive(:close).and_raise(StandardError)
        logger = double
        allow(Delayed::Worker).to receive(:logger).and_return(logger)
        expect(logger).to receive(:debug)
          .with('Unable to close ftp connection to host:port StandardError')
        client.close
      end
    end
  end
end
