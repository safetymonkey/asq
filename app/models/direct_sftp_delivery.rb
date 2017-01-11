# delivery class for direct ftp deliveries
class DirectSftpDelivery < ActiveRecord::Base
  include DeliverableModule
  belongs_to :asq
  crypt_keeper :password, encryptor: :aes_new, key: 'I think super long ' \
    'passwords tend to be the best ones, don\'t you?', salt: 'sodium chloride'

  after_create :create_delivery
  after_save :delete_if_empty
  after_destroy :destroy_delivery

  private

  def deliver_report
    file_name = asq.get_processed_filename
    credentials = {
      host: host, port: port, username: username, password: password
    }
    SftpService.upload_string(credentials, directory, file_name, asq.to_csv)
  end

  def deliver_alarm
    deliver_report
  end

  def deliver_clear
    false
  end

  def delete_if_empty
    destroy if host.blank?
  end

  def meets_sub_requirements?
    !host.blank?
  end
end
