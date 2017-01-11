class FileOptions < ActiveRecord::Base
  belongs_to :asq
  after_save :delete_if_empty

  private

  # Delete this object if all the attributes in it are empty.
  def delete_if_empty
    return false unless delimiter.blank? && quoted_identifier.blank? && (line_end == "\n" || line_end == '\\n') && name.blank? && sub_character.blank?
    destroy
  end
end
