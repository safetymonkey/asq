require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'asq management', type: :feature do
  fixtures :users
  fixtures :databases

  context 'while not logged in' do
    it 'cannot view new asq page' do
      visit 'asqs/new'
      expect(current_path).to eq('/users/sign_in')
    end

    it 'cannot see new asqs link' do
      visit '/'
      expect(page).not_to have_link('New', href: '/asqs/new')
    end

    it 'can view asqs' do
      asq = FactoryGirl.create(:asq)
      visit 'tags'
      expect(page).to have_content(asq.name)
    end
  end

  context 'while logged in' do
    context 'as editor' do
      before(:example) do
        visit 'users/sign_in'
        within('#new_user') do
          fill_in 'user_login', with: 'eeditor'
          fill_in 'user_password', with: 'smada'
        end
        click_button 'Log in'
        click_link 'New'
      end

      it 'has new asq link' do
        visit '/'
        expect(page).to have_link('New', href: '/asqs/new')
      end

      # Do not put forms inside of forms........ What does it all mean.....
      it 'create new asq' do
        within('#new_asq') do
          fill_in 'asq_name', with: 'sampleAsq'
          fill_in 'asq_query', with: 'select 1 as data'
        end
        save_btn = find(:css, 'button.save')
        save_btn.click
        expect(page).to have_content('sampleAsq')
      end

      it 'cannot view monitor options in asq report' do
        expect(page).to have_selector('div.monitor-options', visible: false)
      end

      it 'not able to view direct ftp options' do
        expect(page).not_to have_content('Direct FTP Options')
      end

      it 'not able to view json options' do
        expect(page).not_to have_content('JSON Options')
      end
    end
  end
end
