require 'rails_helper'
require 'capybara/rspec'

unless Settings.ldap_enabled
  RSpec.describe 'the signup process', type: :feature do
      fixtures :users

    before(:all) do
      @ldap_server = Ladle::Server.new(ldif: 'spec/features/test_ldap_dir.ldif')
                                  .start
    end
    after(:all) do
      @ldap_server.stop if @ldap_server
    end

    context 'with valid information' do
      it 'requires admin approval' do
        visit new_user_registration_path
        within('#new_user') do
          fill_in 'user_login', with: 'test_account'
          fill_in 'user_email', with: 'test@account.com'
          fill_in 'user_password', with: 'test_password'
          fill_in 'user_password_confirmation', with: 'test_password'
        end
        click_button 'Sign up'
        expect(page).to have_content 'You have signed up successfully but your account has not been approved by your administrator yet'
      end
    end
  end
end
