require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'the signin process', type: :feature do
  fixtures :users

  before(:all) do
    @ldap_server = Ladle::Server.new(ldif: 'spec/features/test_ldap_dir.ldif')
                                .start
  end
  after(:all) do
    @ldap_server.stop if @ldap_server
  end

  context 'with correct password' do
    it 'signs me in' do
      visit 'users/sign_in'
      within('#new_user') do
        fill_in 'user_login', with: 'aadmin'
        fill_in 'user_password', with: 'smada'
      end
      click_button 'Log in'
      expect(page).to have_content 'Welcome to Asq'
    end
  end

  context 'with incorrect password' do
    it 'shows error message' do
      visit 'users/sign_in'
      within('#new_user') do
        fill_in 'user_login', with: 'aadmin'
        fill_in 'user_password', with: 'smadfa'
      end
      click_button 'Log in'
      expect(page).to have_content 'Invalid username or password.'
    end
  end

  context 'while admin user' do
    before(:example) do
      visit 'users/sign_in'
      within('#new_user') do
        fill_in 'user_login', with: 'aadmin'
        fill_in 'user_password', with: 'smada'
      end
      click_button 'Log in'
    end

    it 'shows admin menu' do
      expect(page).to have_link('Admin')
    end
  end

  context 'while editor' do
    before(:example) do
      visit 'users/sign_in'
      within('#new_user') do
        fill_in 'user_login', with: 'eeditor'
        fill_in 'user_password', with: 'smada'
      end
      click_button 'Log in'
    end

    it 'does not show admin menu' do
      expect(page).not_to have_link('Admin')
    end
  end

  context 'while regular user' do
    before(:example) do
      visit 'users/sign_in'
      within('#new_user') do
        fill_in 'user_login', with: 'rregular'
        fill_in 'user_password', with: 'smada'
      end
      click_button 'Log in'
    end

    it 'does not show admin menu' do
      expect(page).not_to have_link('Admin')
    end
  end
end
