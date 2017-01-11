require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  let(:gon) { RequestStore.store[:gon].gon }

  describe 'GET #index' do
    fixtures :users

    before(:example) do
      sign_in(User.find_by_login('aadmin'))
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'attempts to authorize the user' do
      expect(controller).to receive(:authorize!)
      get :index
    end

    # Gon is a gem that allows vairables to be passed from
    # Rails to Javascript. This test makes sure that it works.
    it 'returns the view property stored in gon' do
      get :index
      expect(gon['view']).to eq('settings#index')
    end

    # Another Gon test. These two tests look for values that
    # are used in the Settings view's Javascript, which is why
    # we're testing them.
    it 'stores the max_db_timeout property with gon' do
      allow(Settings).to receive(:method_missing).with(:max_db_timeout)
        .and_return(10)
      get :index
      expect(gon['max_db_timeout']).to eq(10)
    end

    # There won't be any delayed jobs running during this
    # test, so we have to intercept the call to Dir[dj_path].count
    # and return a known value that we can test against.
    it 'returns the Delayed Jorb worker count' do
      mock_dir = double
      allow(Dir).to receive(:[]).and_return(mock_dir)
      allow(mock_dir).to receive(:count).and_return(5)
      get :index
      expect(assigns(:delayed_job_worker_count)).to eq(5)
    end

    it 'returns the hostname' do
      get :index
      expect(assigns(:asq_hostname)).to eq(Rails.application.hostname)
    end
  end

  describe 'POST #update' do
    it 'attempts to authorize the user' do
      expect(controller).to receive(:authorize!)
      get :update
    end

    # In this test (and others like it), the 'var' parameter is a property
    # of a Setting object. It's not a special keyword or anything. For similar
    # tests, see refresh_controller_spec.rb.
    it 'saves a setting that has been passed in as a paramter' do
      allow(controller).to receive(:authorize!)
      expect(Settings).to receive(:method_missing).with(:var=, 'random_thing')
        .and_return(10)
      post :update, var: 'random_thing'
    end

    it 'redirects to the settings view when complete' do
      allow(controller).to receive(:authorize!)
      post :update
      expect(response).to redirect_to(:settings)
    end
  end

  describe 'GET #single_setting' do
    it 'gets a setting passed in via URL' do
      allow(Settings).to receive(:method_missing).with(:random_thing)
        .and_return(10)
      get :single_setting, var: 'random_thing'
      expect(response.body).to match '10'
    end
  end
end
