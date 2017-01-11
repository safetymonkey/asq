# This class handles Zenoss settings.
class ZenossSettingsController < ApplicationController
  # GET Zenoss settings.
  def index
    authorize! :index, Settings
  end

  # POST Edit Zenoss settings.
  def update
    authorize! :edit, Settings
    params.each do |key, value|
      next if /(utf8|authenticity_token|commit|controller|action)/ =~ key
      Settings.send(key.to_s + '=', value)
    end
    redirect_to zenoss_settings_path
  end
end
