class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Login: every page needs a signed-in user unless a controller says otherwise.
  # The signed-in user's id is kept in the session cookie; Current.user is that user.
  before_action :set_current_user
  before_action :require_login

  helper_method :signed_in?

  # Lets a controller open some or all of its pages to signed-out visitors:
  #   allow_unauthenticated_access only: [ :new, :create ]
  def self.allow_unauthenticated_access(**options)
    skip_before_action :require_login, **options
  end

  private

  def set_current_user
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if signed_in?

    session[:return_to] = request.url if request.get?
    redirect_to new_session_path, alert: "Please log in first."
  end

  def signed_in?
    Current.user.present?
  end

  def log_in(user)
    reset_session
    session[:user_id] = user.id
    Current.user = user
  end

  def log_out
    reset_session
    Current.user = nil
  end
end
