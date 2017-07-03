class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_paper_trail_whodunnit

  helper_method :current_group, :current_role
  helper_method :current_user

  def current_user
    current_person
  end

  def current_group
    return current_person.groups.first
  end

  def current_role
    Membership.where(
      person_id: current_person.id, group_id: current_group.id
    ).first.role
  end

  def validate_admin_permission
    return if controller_name == 'sessions' || current_person.nil?
    render_not_found unless current_person.admin?
  end

  def after_sign_in_path_for(resource)
    if session[:redirect_uri]
      session[:redirect_uri]
    elsif resource.admin?
      admin_dashboard_path
    elsif can? :manage, current_group
      group_dashboard_path(current_group.id)
    else
      group_url(current_group.id)
    end
  end

  def authorize_group_access
    return true unless params[:group_id]
    authorize! :manage, Group.find_by(id: params[:group_id])
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        flash[:alert] = "Access denied. You are not authorized to access the requested page."
        redirect_to group_path(id: current_group.id)
      end
      format.json { head :forbidden }
    end
  end

  private

  def render_not_found
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_group)
  end

  def json_request?
    request.format.json?
  end

  def direction_param
    @direction_param ||= ['asc', 'desc'].include?(params[:direction]) && params[:direction] || nil
  end
end
