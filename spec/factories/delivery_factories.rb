require 'faker'
FactoryBot.define do
  factory :email_delivery do
    to Faker::Internet.safe_email
    from Faker::Internet.safe_email
    subject Faker::Lorem.words.join(' ').titlecase
    body Faker::Lorem.sentences(10).join(' ')
    attach_results true
    asq { build(:asq_with_email) }
  end
end

FactoryBot.define do
  factory :direct_ftp_delivery do
    host Faker::Lorem.words(2).join('')
    port 21
    directory Faker::Lorem.words(2).join('/')
    username Faker::Internet.safe_email
    password Faker::Lorem.words(2).join('')
    asq { build(:asq) }
  end
end

FactoryBot.define do
  factory :direct_sftp_delivery do
    host Faker::Lorem.words(2).join('')
    port 21
    directory Faker::Lorem.words(2).join('/')
    username Faker::Internet.safe_email
    password Faker::Lorem.words(2).join('')
    asq { build(:asq) }
  end
end

FactoryBot.define do
  factory :json_delivery do
    url Faker::Internet.url
    asq { build(:asq) }
  end
end

FactoryBot.define do
  factory :zenoss_delivery do
    asq { build(:asq, query_type: 'monitor') }
    enabled true
  end
end
