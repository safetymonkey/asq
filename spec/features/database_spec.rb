require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'external database management', type: :feature do
  fixtures :users
  fixtures :databases

  before(:all) do
    @ldap_server =
      Ladle::Server
      .new(quiet: true, ldif: 'spec/features/test_ldap_dir.ldif').start
  end
  after(:all) do
    @ldap_server.stop if @ldap_server
  end

  context 'While user is admin' do
    # Find a better way to login to the user page.
    before(:example) do
      visit 'users/sign_in'
      within('#new_user') do
        fill_in 'user_login', with: 'aadmin'
        fill_in 'user_password', with: 'smada'
      end
      click_button 'Log in'
      visit 'databases'
    end

    it 'can view admin page' do
      expect(page).to have_content('Listing databases')
    end

    it 'can add database' do
      first(:link, 'New Database').click
      within('#new_database') do
        fill_in 'database_name', with: 'Test_database'
        fill_in 'database_hostname', with: 'test_host'
        fill_in 'database_username', with: 'asq'
        fill_in 'database_password', with: 'asq'
        fill_in 'database_db_name', with: 'asq'
        fill_in 'database_port', with: '5432'
        select 'PostgreSQL', from: 'database_db_type'
      end
      click_button 'Create Database'
      target_text = 'Password: Yup! A password exists. Edit record to see it.'
      expect(page).to have_content(target_text)
    end

    it 'can edit database connection' do
      edit_btn = first(:css, 'a.edit-btn')
      edit_btn.click
      fill_in 'Name', with: 'edited_database_name'
      click_button('Update Database')
      expect(page).to have_content('Name: edited_database_name')
    end

    # There is a JS alert that is not stopping the test from removing the database entry.
    # Will need to investigate this issue.
    it 'can remove database connection' do
      initial_rows = page.all('table tr').count
      del_btn = first(:css, 'a.delete-btn')
      del_btn.click
      expect(page.all('table tr').count).to eq(initial_rows - 1)
    end

    it 'can test database connection', js: true do
      visit 'databases/new'
      click_button 'Test Database Connection'
      expect(page).to have_content("Error: ")
    end
  end

  context 'while user is not an admin' do
    before(:example) do
    visit 'users/sign_in'
    within('#new_user') do
      fill_in 'user_login', with: 'rregular'
      fill_in 'user_password', with: 'smada'
    end
    click_button 'Log in'
    visit 'databases'
    end
    it 'does not allow users to view the page' do
      expect(current_path).to eq('/')
    end
  end

  context 'while user is not logged in' do
    it 'does not allow users to view the page' do
      visit 'databases'
      expect(current_path).to eq('/')
    end
  end
end
