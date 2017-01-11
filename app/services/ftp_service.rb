require 'net/ftp'

# Service class to upload text data to an FTP location
class FtpService
  # tests if ftp can connect, nav to dir, and write to dir
  def self.test(credentials, directory)
    @ftp = FtpClient.new(credentials)
    @ftp.chdir(directory)
    fail 'Unable to write to directory' unless @ftp.write?
    { status: 'OK', message: 'OK' }
  rescue => e
    { status: 'FAIL', message: "#{e}" }
  ensure
    @ftp.close if @ftp
  end

  # uploads text string to file
  def self.upload_string(credentials, directory, file_name, string)
    @ftp = FtpClient.new(credentials)
    @ftp.chdir(directory)
    @ftp.upload_string(string, file_name)
  rescue => e
    raise "Upload failed: #{e}"
  ensure
    @ftp.close if @ftp
  end
end
