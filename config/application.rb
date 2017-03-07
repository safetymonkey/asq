require File.expand_path('../boot', __FILE__)

require 'csv'
require 'json'
require 'rails/all'
require 'net/ftp'
require 'stringio'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AsqApplication
  class Application < Rails::Application
    config.filter_parameters += [:password]
    config.middleware.use ActionDispatch::Flash
    config.active_record.time_zone_aware_types = [:datetime]

    def hostname
      return @hostname unless @hostname.blank?
      hostname = `hostname`.strip
      Rails.logger.info "Setting application.hostname to #{hostname}"
      @hostname = hostname
    end

    def archive_file_dir
      Rails.configuration.archive_file_dir
    end

    def feature_archive_file_enabled
      Rails.configuration.archive_file_enabled
    end
  end
end

class String
  def is_json?
    begin
      JSON.parse(self).length
    rescue JSON::ParserError => e
      return false
    end
    true
  end
end

class Net::FTP
  def puttextcontent(content, remotefile, &block)
    f = StringIO.new(content)
    begin
      storlines('STOR ' + remotefile, f, &block)
    ensure
      f.close
    end
  end
end

# As of this writing, the fun_sftp gem we're using is 1.1.0, from March 2016.
# That version of the gem doesn't have methods that we need, such as .close
# or .write, so we're monkey patching them into the gem here. If that gem ever
# gets updated with suitable methods, we can remove this code.
module FunSftp
  class SFTPClient
    def close
      client.session.close
    end
  end
end
