require 'rails_helper'

RSpec.describe Activity, type: :model do
  let(:activity) { Activity.new }
  describe '.formatted_time' do
    it 'formats time correctly' do
      activity.created_at = '2015-01-01 12:00'
      expect(activity.formatted_time).to eq('01-01-2015 04:00:00 PST')
    end
  end

  describe '.archive_file' do
    it 'creates ArchivedFile' do
      activity.archive_file('name.txt', 'contents')
      expect(activity.archived_file).to be_an_instance_of(ArchivedFile)
    end
  end

  describe 'on delete' do
    it 'removes associated ArchivedFile' do
      activity.archive_file('name.txt', 'contents')
      file_id = activity.archived_file.id
      activity.destroy
      expect { ArchivedFile.find(file_id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
