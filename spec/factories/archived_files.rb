require 'faker'
FactoryGirl.define do
  factory :archived_file do
    name Faker::Lorem.words(1).first + '.txt'
  end
end
