class RefreshController < ApplicationController
  def index
    @title = 'Refresh'
    if params[:id]
      # If we were passed a single ID, refresh only that Asq and redirect to the
      # Asq's page.
      @asq = Asq.find_by_id(params[:id])
      @asq.refresh(true)
      redirect_to asq_path(@asq.id), notice: "#{@asq.name} is being refreshed."
    else
      # If we weren't passed an ID, check all Asqs to see if it's time for them
      # to refresh.

      # Compare Settings.vip_name to the current hostname. Raise an error if
      # this check fails. If the hostname and Settings.vip_name match (or if
      # vip_name is empty), refresh all the Asqs.
      if Settings.vip_name.empty?
        Settings.last_host_check = 'OK'
        refresh_asqs_in_need
      else
        begin
          require 'open-uri'
          # By default, Rails apps can't listen for web requests while
          # responding to web requests at the same time. You have to do
          # some fancy stuff to fully test this part of the code.

          # Check out refresh_readme.txt for more details.
          url = URI.parse("http://#{Settings.vip_name}/settings/hostname")
          @reported_host_name = open(url, read_timeout: 5) { |io| io.read }
        rescue => e
          logger.warn 'Exception occured while trying to check primary host.' \
            "Check VIP name. Error message: #{e}"
          Settings.last_host_check = e.message
          return
        end
        # The VIP that this service lives behind has a single responding
        # server. We've just used http://#{Settings.vip_name}/settings/host_name
        # to see what the hostname of that server is. If that hostname is
        # the same as ours, then we can proceed with the refresh action.
        if @reported_host_name == Rails.application.hostname
          Settings.last_host_check = 'OK'
          refresh_asqs_in_need
          notice = 'Checking for Asqs to refresh...'
        else
          notice = 'Current host is not primary, so refresh ' \
            'request is being ignored.'
        end
      end
      redirect_to root_path, notice: notice
    end
  end

  private

  def refresh_asqs_in_need
    Asq.all.each do |asq|
      if asq.needs_refresh?
        @asq = asq
        @asq.refresh(true)
      end
    end
  end
end
