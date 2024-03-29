# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_authorization, except: [:render_not_found]
  helper_method :current_user
  helper_method :current_user?
  helper_method :logged_in?
  helper_method :client?
  helper_method :freelancer?
  helper_method :admin?
  helper_method :create_instance
  helper_method :redirect_to_root_with_err
  helper_method :redirect_to_root_with_notice

  rescue_from ActionController::RoutingError, with: :render_not_found

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user?(user)
    current_user == user
  end

  def logged_in?
    !current_user.nil?
  end

  def admin?
    current_user&.admin?
  end

  def client?
    current_user&.client?
  end

  def freelancer?
    current_user&.freelancer?
  end

  def require_admin
    redirect_to_root_with_err('You are not authorized to view this page') unless admin?
  end

  def require_authorization
    redirect_to new_session_path, flash: { error: 'Please sign in' } unless logged_in?
  end

  def redirect_logged_in_users
    redirect_to_root_with_notice('You are already signed in') if logged_in?
  end

  def render_not_found
    redirect_to_root_with_err('The page you are looking for cannot be shown')
  end

  def create_instance(instance, success_path, success_message, failure_message, failure_view)
    if instance.save
      redirect_to success_path, flash: { notice: success_message }
    else
      flash.now[:error] = failure_message
      render failure_view, status: :unprocessable_entity
    end
  end

  def redirect_to_root_with_err(error_message)
    redirect_to root_path, flash: { error: error_message }
  end

  def redirect_to_root_with_notice(notice)
    redirect_to root_path, flash: { notice: }
  end
end
