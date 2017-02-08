class RegistrationsController < Devise::RegistrationsController
  before_action :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:login, :email, :password, :password_confirmation, :remember_me)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:login, :email, :password, :password_confirmation,
               :current_password)
    end
  end
end
