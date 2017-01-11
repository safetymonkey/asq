# Service class to write strings to file locations.
class FileDeliveryService
  def self.write_to_local_file(dirname, filename, file_string)
    if Dir.exist? dirname
      path = File.join(dirname, filename)
      new_file = File.new(path, 'w')
      new_file.write(file_string)
      new_file.close
    else
      fail ArgumentError, 'Specified path name does not exist'
    end
  end
end
