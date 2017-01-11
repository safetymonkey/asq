class ActivityController < ApplicationController
  before_filter :authorize!,
                except: [:show, :index, :ajax, :show_partial]

  def index
    query = 'activity_type <= ?'
    log_level = params[:log_level] || 1
    @activities = Activity.paginate(page: params[:page], per_page: 50)
                  .where(actable_type: 'Asq')
                  .where(query, log_level)
                  .order('created_at DESC')
  end
end
