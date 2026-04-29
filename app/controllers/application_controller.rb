class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_organization, :current_project

  private

  def current_organization
    @current_organization ||= if params[:organization_slug].present?
      current_user.organizations.find_by!(slug: params[:organization_slug])
    end
  end

  def current_project
    @current_project ||= if params[:project_key].present? && current_organization
      current_organization.projects.find_by!(key: params[:project_key].upcase)
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
