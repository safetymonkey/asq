require 'faker'
FactoryBot.define do
  factory :archived_file do
    name { Faker::Lorem.words(number: 1).first + '.txt' }
  end
end
