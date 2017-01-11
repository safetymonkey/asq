# Polymorphic class to attach 'activity' logging objects to any model.
class Activity < ActiveRecord::Base
  enum activity_type: [:fatal, :error, :warn, :info, :debug, :trace]
  belongs_to :actable, polymorphic: true
  has_one :archived_file, dependent: :destroy

  def formatted_time(timezone = 'America/Los_Angeles')
    created_at.in_time_zone(timezone).strftime('%m-%d-%Y %H:%M:%S %Z')
  end

  # create an ArchivedFile using file_name and content, and attach it to this
  # Activity (for example, archiving a file with a delivery activity)
  def archive_file(file_name, content)
    file = ArchivedFile.create(
      name:  file_name,
      content: content)
    self.archived_file = file
    save
  end
end
