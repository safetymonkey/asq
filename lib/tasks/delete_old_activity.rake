# rake task to delete all old activity
namespace :delete do
  desc 'Delete activity records older than 30 days'
  task :old_activity, [:days] => :environment do |_, args|
    day_val = args.days.to_i > 0 ? args.days.to_i : 30
    puts "Deleting activity older than #{day_val} day(s)"
    Activity.where('created_at < ?', day_val.days.ago).each(&:destroy)
  end

  desc 'Delete archived files older than 30 days'
  task :old_archived_files, [:days] => :environment do |_, args|
    day_val = args.days.to_i > 0 ? args.days.to_i : 30
    puts "Deleting archived files older than #{day_val} day(s)"
    ArchivedFile.where('created_at < ?', day_val.days.ago).each(&:destroy)
  end
end
