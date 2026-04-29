class OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]

  def index
    @organizations = policy_scope(Organization)
  end

  def show
    authorize @organization
    @projects = policy_scope(@organization.projects)
    @members  = @organization.memberships.includes(:user)
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    authorize @organization

    if @organization.save
      # Creator automatically becomes owner
      @organization.memberships.create!(user: current_user, role: :owner)
      redirect_to @organization, notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @organization
  end

  def update
    authorize @organization

    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @organization
    @organization.destroy!
    redirect_to organizations_path, notice: "Organization was successfully deleted."
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:slug])
  end

  def organization_params
    params.require(:organization).permit(:name, :slug, :description)
  end
end
