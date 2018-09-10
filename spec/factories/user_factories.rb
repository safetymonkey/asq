FactoryBot.define do
  factory :user do
    login 'tuser'
    email 'tuser@yourdomain.com'
    name 'Test User'
    is_editor true
    last_sign_in_at Time.gm(2015, 1, 1)
    approved true
  end

  factory :admin_user, class: User do
    login 'aadmin'
    email 'alexandra@example.org'
    is_admin true
    is_editor true
    approved true
  end

  factory :editor_user, class: User do
    login 'eeditor'
    email 'erin@example.org'
    is_admin false
    is_editor true
    approved true
  end

  factory :regular_user, class: User do
    login 'rregular'
    email 'ronnie@example.org'
    is_admin false
    is_editor false
    approved true
  end
end
