# Service class to upload text data to a remote location
# using SFTP
class SftpService
  # Tests if SFTP can connect and write to a directory.
  def self.test(credentials, directory)
    @sftp = SftpClient.new(credentials)
    @sftp.chdir(directory)
    unless @sftp.can_write_files?
      raise "Unable to write to remote directory: #{directory}"
    end
    { status: 'OK', message: 'OK' }
  rescue => e
    { status: 'FAIL', message: e.to_s }
  ensure
    @sftp.close if @sftp
  end

  # uploads text string to file
  def self.upload_string(credentials, directory, file_name, string)
    @sftp = SftpClient.new(credentials)
    @sftp.chdir(directory)
    @sftp.upload_string(string, file_name)
  rescue StandardError => e
    raise "Upload failed: #{e}"
  ensure
    @sftp.close if @sftp
  end
end
