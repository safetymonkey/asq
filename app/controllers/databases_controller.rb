class DatabasesController < ApplicationController
  before_action :set_database, only: [:show, :edit, :update, :destroy]
  before_filter do
    params[:database] &&= database_params
  end
  load_and_authorize_resource

  # GET /databases
  # GET /databases.json
  def index
    @databases = Database.all.order(:name)
  end

  # GET /databases/1
  # GET /databases/1.json
  def show
  end

  # GET /databases/new
  def new
    @database = Database.new
  end

  # GET /databases/1/edit
  def edit
  end

  # POST /databases
  # POST /databases.json
  def create
    @database = Database.new(database_params)

    respond_to do |format|
      if @database.save
        format.html { redirect_to @database, notice: 'Database was successfully created.' }
        format.json { render action: 'show', status: :created, location: @database }
      else
        format.html { render action: 'new' }
        format.json { render json: @database.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /databases/1
  # PATCH/PUT /databases/1.json
  def update
    respond_to do |format|
      if @database.update(database_params)
        format.html { redirect_to @database, notice: 'Database was successfully updated.' }
        format.json { render action: 'show', status: :ok, location: @database }
      else
        format.html { render action: 'edit' }
        format.json { render json: @database.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /databases/1
  # DELETE /databases/1.json
  def destroy
    @database.destroy
    respond_to do |format|
      format.html { redirect_to databases_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_database
    @database = Database.find(params[:id])
  end

  # Never trust params from the scary internet, only allow the white list params
  def database_params
    params.require(:database).permit(:name, :hostname, :db_type, :username,
                                     :password, :db_name, :port)
  end
end
