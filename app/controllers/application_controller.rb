class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :skip_app_authentication?
  before_action :configure_permitted_parameters, if: :user_devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :department, :campus_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role, :department, :campus_id])
  end

  def skip_app_authentication?
    request.path.start_with?("/admin")
  end

  def user_devise_controller?
    devise_controller? && resource_name == :user
  end
end
