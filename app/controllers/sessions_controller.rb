# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_authorization, only: %i[index new create]
  before_action :redirect_logged_in_users, only: %i[new create]

  def index
    redirect_to new_session_path
  end

  def new; end

  def create
    @user = User.find_by(email: params[:email].downcase)

    return handle_invalid_authentication unless @user&.authenticate(params[:password])
    return handle_unconfirmed_email(@user) unless @user.email_confirmed

    session[:user_id] = @user.id
    handle_successful_authentication
  end

  def destroy
    session[:user_id] = nil
    redirect_to_root_with_notice('Logged out')
  end

  private

  def handle_invalid_authentication
    flash.now[:error] = 'Invalid credentials. Please try again'
    render :new, status: :unprocessable_entity
  end

  def handle_successful_authentication
    if client?
      redirect_to projects_path, flash: { notice: 'Logged in as client!' }
    elsif freelancer?
      redirect_to bids_path, flash: { notice: 'Logged in as freelancer!' }
    else
      redirect_to_root_with_notice('Logged in as admin!')
    end
  end

  def handle_unconfirmed_email(user)
    redirect_to_root_with_err('Your account has been rejected!') and return if user.rejected?

    redirect_to_root_with_err('Please activate your account!')
  end
end
