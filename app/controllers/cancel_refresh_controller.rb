class CancelRefreshController < ApplicationController
  def index
    @title = 'Cancel Refresh'
    if params[:id]
      # If we were passed a single ID, refresh that asq only and redirect to the
      # last page we were on.
      @asq = Asq.find_by_id(params[:id])
      @asq.cancel_refresh
      redirect_to :back, notice: "#{@asq.name} has cancelled its refresh."
    else
    end

  rescue ActionController::RedirectBackError
    # If you went to a single-ID cancel_refresh page directly, redirect to home
    if params[:id]
      redirect_to asq_path(@asq)
    else redirect_to root_path
    end
  end
end

