# Used by the Settings UI and Ajax endpoint
class SettingsController < ApplicationController
  # GET /settings
  def index
    authorize! :index, Settings
    gon.view = 'settings#index'
    gon.max_db_timeout = Settings.max_db_timeout
    # We can tell how maby delayed job workers there are by
    # examining the number of delayed_job files in <AsqRoot>/tmp/pids
    dj_path = Rails.root.join('tmp', 'pids', 'delayed_job.*')
    @delayed_job_worker_count = Dir[dj_path].count { |file| File.file?(file) }
    @asq_hostname = Rails.application.hostname
  end

  # POST /settings
  def update
    authorize! :edit, Settings
    params.each do |key, value|
      # We don't care about any settings with names that match the below string.
      next if key =~ /(utf8|authenticity_token|commit|controller|action)/
      # This is effecitely a complete refresh of each setting, even if just a
      # single one was changed.
      Settings.send(key.to_s + '=', value)
    end
    redirect_to settings_path
  end

  # GET /settings/:var
  def single_setting
    # Pass in a single setting name, get that setting value back in raw text.
    render text: Settings.send(params['var'])
  end
end
