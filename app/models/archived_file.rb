# Class is used to preserve delivered files
class ArchivedFile < ActiveRecord::Base
  belongs_to :activity
  # used only for setting. content should never be "retrieved"
  attr_accessor :content
  after_create :build_file
  after_destroy :delete_file

  # write a string to a text file retrievable at full_path
  def write(content)
    target = full_path
    Delayed::Worker.logger.info "Writing archive file: #{target}"
    File.open(target, 'w:UTF-8') do |f|
      f.write(content)
    end
  rescue StandardError => e
    Delayed::Worker.logger.error "Unable to write archive file: #{e}"
  end

  # path where the content file should be if it exists
  def full_path
    File.join(target_dir, target_name)
  end

  private

  # write file immediately if content provided on init
  def build_file
    write(content) unless content.blank?
  end

  # unique file name for raw text
  def target_name
    format('%010d', id) + '.dat'
  end

  def target_dir
    target = Rails.application.archive_file_dir
    Dir.mkdir(target) unless File.exist?(target)
    target
  end

  # used to delete the text file if object is destroyed
  def delete_file
    File.delete(full_path)
  rescue StandardError => e
    logger.error "Unable to delete archive file: #{e}"
  end
end
