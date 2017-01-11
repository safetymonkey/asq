require 'faker'
FactoryGirl.define do
  factory :asq do
    name Faker::Lorem.words.join(' ')
    description Faker::Lorem.sentences.join(' ')
    query 'Select 1 as data'
    query_type 'report'
    alert_value 0
    result '[{"results":"2015-10-14 12:06:28.300141-07"}]'
    status 'clear_still'

    factory :asq_with_email do
      email_alert true
      deliver_on_every_refresh true
      deliver_on_all_clear true
      email_attachment true
    end

    factory :asq_in_alert do
      status 'alert_new'
    end
  end
end
