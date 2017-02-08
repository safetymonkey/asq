# The ApplicationController class gets executed on all pages.
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Uncomment the below if you have re-enabled DeviseLdapAuthenticatable
  # rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
  #   render text: exception, status: 500
  # end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/', alert: "Unable to access requested page: #{exception.message}"
  end

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :display_release_notes
  before_action :pass_environment
  before_action lambda{
    flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] &&
                                                     flash[:notice]
  }

  before_action { render text: "Sorry, friendo. ASQ doesn't support Internet Explorer.
     Please use a different browser." if browser.ie? }

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  # We need to pass in the environment into gon so we can make the decision
  # whether or not to execute certain Javascript, like Google Analytics
  def pass_environment
    gon.environment = Rails.env
  end

  # Flashes a notification about release notes if the user hasn't seen them all
  def display_release_notes
    return unless current_user && params[:controller] != 'release_notes'

    release_notes = ReleaseNotes.new(current_user.last_release_note_viewed)
    return unless release_notes.has_notes?
    update = %(New release notes are available, please \
      <a href="/release_notes">review them</a> to clear this alert.)
    flash.now[:notice] = update
  end

  def redirect_with_delay(url, delay = 0)
    @redirect_url = url
    @redirect_delay = delay
    render
  end

  private

  def record_not_found
    render template: 'errors/404', layout: 'layouts/application', status: 404
  end
  # end private

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:login, :email])
  end
end
