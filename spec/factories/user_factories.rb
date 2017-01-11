FactoryGirl.define do
  factory :user do
    login "tuser"
    email "tuser@yourdomain.com"
    name "Test User"
    is_editor true
    last_sign_in_at Time.gm(2015,1,1,)
  end
end