# Controller for all routes starting in ASQ, inlcluded update, search, edit,
# and index actions. Refreshes are handled by the refresh controller. Updates
# are handled by the update action; the edit action only generates the edit
# form.
class AsqsController < ApplicationController
  before_action :set_asq, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!,
                except: [:show, :index, :ajax, :show_partial, :activity_rows]
  before_action do
    params[:asq] &&= all_params
  end
  load_and_authorize_resource
  skip_authorize_resource only: :activity_rows

  # GET /asqs
  # GET /asqs.json
  def index
    @up_to_date = check_if_asqs_up_to_date
    # If we're passed a tag in the params...
    init_results_for_tag && return if params[:tag]
    # If we're passed a search string...
    init_results_for_search && return if params[:search]
    # Otherwise, show all the asqs
    @asqs = Asq.joins("left join asq_statuses on asq_statuses.status_enum = \
                 asqs.status")
               .order("disabled ASC, query_type ASC, \
                 asq_statuses.sort_priority ASC")
               .paginate(page: params[:page])
  end

  # GET /asqs/1
  # GET /asqs/1.json
  def show
    set_asq
    @title = @asq.name
    @up_to_date = check_if_asqs_up_to_date

    # Displays the HTML, CSV of current result set, or JSON
    respond_to do |format|
      format.html
      format.json { render json: @asq }
      format.csv { generate_csv }
    end
  end

  def show_partial
    set_asq
  end

  def activity_rows
    set_asq
    # 'page' size for activity log
    limit = 75
    # log level (show all greater or equal to this level)
    log_level = 3
    # last_id or max int
    last_id = params[:last_id] || 2_147_483_647
    # next 'page' if last id is provided
    query = 'activity_type <= ? and id < ?'
    @activities = @asq.activities.where(query, log_level, last_id)
                      .order('created_at DESC').limit(limit)
    raise ActionController::RoutingError, 'Not Found' if @activities.blank?
    render partial: 'asqs/activity_rows_page', layout: false
  end

  def ajax
    set_asq
    @attribute = {}
    # 'attribute' is the name of the wildcard passed in the URL.
    # See the routes file for more info.
    begin
      @attribute[params[:attribute]] = @asq.send(params[:attribute])
    rescue
      @attribute['alert'] = 'The asq attribute you are looking for does' \
        ' not exist.'
    end
    render json: @attribute, layout: false
  end

  # GET /asqs/new
  def new
    @title = 'New Asq'
    @asq = Asq.new(created_by: current_user.email, created_on: DateTime.now)
    create_children
  end

  # GET /asqs/1/edit
  def edit
    @title = Asq.find_by_id(params[:id]).name
    create_children
  end

  # GET /asqs/1/edit
  def details
    @title = Asq.find_by_id(params[:id]).name
    gon.details_view = true
    @details_view = true
    create_children
  end

  # POST /asqs
  def create
    @asq = Asq.new(params[:asq])
    # TODO: Asq created_by and modified_by should link to a user, not store
    # their login name as plain text
    @asq.created_by = current_user.login
    @asq.created_on = DateTime.now
    create_asq
  end

  # PATCH/PUT /asqs/1
  def update
    @asq.modified_by = current_user.email
    @asq.modified_on = DateTime.now
    respond_update_failed unless @asq.update(params[:asq])
    @asq.log('info', "Updated by #{current_user.name}")
    respond_update_succeeded
  end

  # DELETE /asqs/1
  def destroy
    @asq.destroy
    respond_to do |format|
      format.html { redirect_to asqs_path }
      format.json { head :no_content }
    end
  end

  private

  def create_children
    @asq.build_file_options if @asq.file_options.nil?
    [@asq.email_deliveries,
     @asq.json_deliveries,
     @asq.zenoss_deliveries,
     @asq.direct_ftp_deliveries,
     @asq.direct_sftp_deliveries].each do |delivery|
      delivery.build if delivery.empty?
    end
  end

  # Find the most recently run asq and see how long ago it was refreshed.
  # Should help catch if the refresh cron job has failed for some reason
  def check_if_asqs_up_to_date
    asq = Asq.all.order(last_run: :desc).limit(1)[0]
    return true if !asq.nil? && asq.last_run > Time.now - 20.minutes
    false
  end

  def generate_csv
    send_data(
      FileOutputService.to_csv(@asq.result, @asq.file_options),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=\"#{@asq.get_processed_filename}\""
    )
  rescue RuntimeError => e
    redirect_to asq_path(@asq),
                alert: "<b>File could not be created:</b> #{e}"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_asq
    id = params[:id]
    if id.to_i > 0 # Look up asq by ID if passed is a number
      @asq = Asq.find(id)
    elsif id.to_i == 0 # Otherwise, look up the name
      # @asq = Asq.find_by_name(params[:id])
      @asq = Asq.where('lower(name) = ?', id.downcase).first
    end
  end

  # use params[:tag] to find asqs
  def init_results_for_tag
    # only show asqs with that tag
    @title = "Tag: #{params[:tag]}"
    @asqs = Asq.tagged_with(params[:tag]).paginate(page: params[:page])
               .joins("left join asq_statuses on asq_statuses.status_enum = \
                 asqs.status")
               .order("disabled ASC, query_type ASC, \
                 asq_statuses.sort_priority ASC")
  end

  # use params[:search] to find asqs; if only one result, redirect to asq
  def init_results_for_search
    # try to find asqs and tags that match search string
    search_string = params[:search].downcase
    @title = "Search for \"#{params[:search]}\""
    @matched_names = search_asqs_by_column('name', search_string)
    @matched_queries = search_asqs_by_column('query', search_string)
    @matched_tags = Asq.tagged_with(search_string.split(' '), wild: true)
    @matched_creator = Asq.where(created_by: search_string)
    @matched_modifier = Asq.where(modified_by: search_string)
    sort_matched_arrays
    redirect_if_single_result
  end

  # userd for search; resusable method to find asqs by search string and
  # column name
  def search_asqs_by_column(column_name, search_string)
    Asq.where("#{column_name} ~* ?", "(#{search_string.tr(' ', '|')})")
  end

  # used for search; sorts each of the "matched" arrays to correct asq display
  # order
  def sort_matched_arrays
    matched_arrays = [@matched_names, @matched_queries, @matched_tags,
                      @matched_creator, @matched_modifier]
    matched_arrays.each do |array|
      array.joins("left join asq_statuses on asq_statuses.status_enum = \
             asqs.status")
           .order("disabled ASC, query_type ASC, \
             asq_statuses.sort_priority ASC")
    end
  end

  # used for search; if one result, redirect to asq
  def redirect_if_single_result
    redirect_to asq_path(one_result) if one_result
  end

  # used for search; determine if there is only on result across all matched
  # arrays
  def one_result
    matched_combined = @matched_names.ids + @matched_tags.ids +
                       @matched_queries.ids + @matched_creator.ids +
                       @matched_modifier.ids
    return Asq.find(matched_combined[0]) if matched_combined.length == 1
    false
  end

  def respond_update_succeeded
    redirect_to asq_path(@asq), notice: 'Asq was successfully updated.'
  end

  def respond_update_failed(format)
    format.html do
      render action: 'edit'
    end
    format.json do
      render json: @asq.alerts, status: :unprocessable_entity
    end
  end

  def create_asq
    respond_to do |format|
      if @asq.save
        @asq.log('info', "Created by #{current_user.name}")
        save_success(format)
      else
        save_fail(format)
      end
    end
  end

  def save_fail(format)
    format.html do
      create_children
      render action: 'new'
    end
    format.json do
      render json: @asq.alerts, status: :unprocessable_entity
    end
  end

  def save_success(format)
    format.html do
      redirect_to asq_path(@asq), notice: 'Asq was successfully created.'
    end
    format.json do
      render action: 'show', status: :created, location: asq_path(@asq)
    end
  end

  # Never trust parameters from the scary internet, only allow white listed
  # through. Broken up by model for readability and linting.

  def all_params
    p = asq_params
    p.merge!(schedule_params)
    p.merge!(email_delivery_params)
    p.merge!(json_delivery_params)
    p.merge!(direct_ftp_delivery_params)
    p.merge!(direct_sftp_delivery_params)
    p.merge!(file_option_params)
    p.merge!(zenoss_delivery_params)
  end

  def asq_params
    params.require(:asq).permit(
      :name, :query, :database_id, :created_by, :modified_by, :created_on,
      :modified_on, :tag_list, :email_alert, :description,
      :alert_result_type, :alert_operator, :alert_value, :disabled,
      :deliver_on_every_refresh, :deliver_on_all_clear, :disable_auto_refresh,
      :post_json_on_alarm, :query_type, :post_json_url
    )
  end

  def schedule_params
    params.require(:asq).permit(
      schedules_attributes: [:id, :type, :param, :time, :time_zone, :_destroy]
    )
  end

  def email_delivery_params
    params.require(:asq).permit(
      email_deliveries_attributes:
        [:id, :to, :from, :subject, :body, :attach_results, :_destroy]
    )
  end

  def json_delivery_params
    params.require(:asq).permit(
      json_deliveries_attributes: [:id, :url, :_destroy]
    )
  end

  def direct_ftp_delivery_params
    params.require(:asq).permit(
      direct_ftp_deliveries_attributes:
        [:id, :host, :port, :username, :password, :directory, :_destroy]
    )
  end

  def direct_sftp_delivery_params
    params.require(:asq).permit(
      direct_sftp_deliveries_attributes:
        [:id, :host, :port, :username, :password, :directory, :_destroy]
    )
  end

  def file_option_params
    params.require(:asq).permit(
      file_options_attributes:
        [:id, :name, :delimiter, :line_end, :quoted_identifier, :sub_character]
    )
  end

  def zenoss_delivery_params
    params.require(:asq).permit(
      zenoss_deliveries_attributes: [:id, :enabled, :_destroy]
    )
  end
end
