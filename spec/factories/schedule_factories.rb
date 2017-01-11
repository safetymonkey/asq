FactoryGirl.define do
  factory :schedule do
  end

  factory :weekly_schedule do
    time Time.gm(2001, 01, 01, 12, 00)
    param 2
  end
end
