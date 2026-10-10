class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.authenticate_by(email_address: params[:email_address], password: params[:password]))
      return_to = session[:return_to]
      log_in(user)
      redirect_to return_to || root_path, notice: "Welcome back, #{user.name}."
    else
      flash.now[:alert] = "Try another email address or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: "You are logged out."
  end
end
