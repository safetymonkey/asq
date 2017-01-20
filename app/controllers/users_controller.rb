class UsersController < ApplicationController
  before_action do
    params[:user] &&= user_params
  end

  def index
    @users = User.order(:login).paginate(page: params[:page])
    @title = 'Users'
  end

  def show
    @user = User.find(params[:id])
    @title = "User: #{@user.login}"
  end

  # GET /users/new
  def new
    @title = 'New User'
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @title = "User: #{@user.login}"
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: users_path }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render action: 'show', status: :ok, location: @user }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { head :no_content }
    end
  end

  def user_params
    params.require(:user).permit(:last_sign_in_at)
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow white-listed parameters through
    def user_params
      params.require(:user).permit(:is_admin, :is_editor, :login,
                                   :last_release_note_viewed)
    end
end
