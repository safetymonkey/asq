require 'rails_helper'

RSpec.describe StatusController, type: :controller do
  let(:vars_hash) do
    {
      time_since_last_update: Faker::Lorem.words.join,
      delayed_job_queue_size: Faker::Lorem.words.join,
      delayed_job_worker_count: Faker::Lorem.words.join,
      cron_exists: Faker::Lorem.words.join,
      last_host_check: Faker::Lorem.words.join,
      system_in_error: false,
      error_text: 'HEALTHY'
    }
  end

  before(:each) do
    allow(SystemStatus).to receive(:vars_hash).and_return(vars_hash)
  end

  it 'index assigns appropriate instance variables for view' do
    get :index
    expect(assigns(:time_since_last_update)).to eq(vars_hash[:time_since_last_update])
    expect(assigns(:delayed_job_queue_size)).to eq(vars_hash[:delayed_job_queue_size])
    expect(assigns(:delayed_job_worker_count)).to eq(vars_hash[:delayed_job_worker_count])
    expect(assigns(:cron_exists)).to eq(vars_hash[:cron_exists])
    expect(assigns(:last_host_check)).to eq(vars_hash[:last_host_check])
    expect(assigns(:system_in_error)).to eq(vars_hash[:system_in_error])
    expect(assigns(:title)).to eq('System Status')
  end

  it 'nagios generates appropriate text for scraper' do
    get :nagios
    status = %({"system_status":"#{vars_hash[:error_text]}"})
    expect(response.body).to include(status)
  end
end
