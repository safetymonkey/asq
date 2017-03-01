require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'the signup process', type: :feature do
  fixtures :users

  context 'with valid information' do
    it 'signs me up' do
      visit new_user_registration_path
      within('#new_user') do
        fill_in 'user_login', with: 'test_account'
        fill_in 'user_email', with: 'test@account.com'
        fill_in 'user_password', with: 'test_password'
        fill_in 'user_password_confirmation', with: 'test_password'
      end
      click_button 'Sign up'
      expect(page).to have_content 'Welcome to Asq'
      expect(page).to have_content 'test_account' # Username shown in navbar
    end
  end
end
