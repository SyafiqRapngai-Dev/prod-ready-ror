class ProjectMembersController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_project_member, only: [ :update, :destroy ]

  def index
    @project_members = @project.project_members.includes(:user)
    authorize ProjectMember
  end

  def new
    @project_member = @project.project_members.build
    authorize @project_member
  end

  def create
    invited_user = User.find_by(email: project_member_params[:email])

    if invited_user.nil?
      redirect_to organization_project_members_path(@organization, @project),
                  alert: "No user found with that email address."
      return
    end

    @project_member = @project.project_members.build(
      user: invited_user,
      role: project_member_params[:role] || :member
    )
    authorize @project_member

    if @project_member.save
      redirect_to organization_project_members_path(@organization, @project),
                  notice: "#{invited_user.name} has been added to the project."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @project_member

    if @project_member.update(role: project_member_params[:role])
      redirect_to organization_project_members_path(@organization, @project),
                  notice: "Member role was updated."
    else
      redirect_to organization_project_members_path(@organization, @project),
                  alert: "Could not update member role."
    end
  end

  def destroy
    authorize @project_member
    @project_member.destroy!
    redirect_to organization_project_members_path(@organization, @project),
                notice: "Member was removed from the project."
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:organization_slug])
  end

  def set_project
    @project = @organization.projects.find_by!(key: params[:project_key].upcase)
  end

  def set_project_member
    @project_member = @project.project_members.find(params[:id])
  end

  def project_member_params
    params.require(:project_member).permit(:email, :role)
  end
end
