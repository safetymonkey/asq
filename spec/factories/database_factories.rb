require 'faker'
FactoryGirl.define do
  factory :database do
    name Faker::Lorem.words.join(' ')
  end
end
