class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :authenticate_user!
  around_action :use_user_time_zone, if: :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from NotAuthorizedError, with: :render_forbidden

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    return if current_user

    session[:return_to] = request.fullpath if request.get?
    redirect_to new_session_path, alert: t("sessions.required")
  end

  def use_user_time_zone(&)
    Time.use_zone(current_user.time_zone, &)
  end

  def render_not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json { render json: { error: "not_found" }, status: :not_found }
    end
  end

  def render_forbidden
    respond_to do |format|
      format.html { redirect_back_or_to root_path, alert: t("errors.forbidden") }
      format.json { head :forbidden }
    end
  end
end
