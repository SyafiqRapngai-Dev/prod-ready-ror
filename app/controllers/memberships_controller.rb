class MembershipsController < ApplicationController
  before_action :set_organization
  before_action :set_membership, only: [ :destroy ]

  def index
    @memberships = @organization.memberships.includes(:user)
    authorize @memberships
  end

  def new
    @membership = @organization.memberships.build
    authorize @membership
  end

  def create
    invited_user = User.find_by(email: membership_params[:email])

    if invited_user.nil?
      redirect_to organization_memberships_path(@organization),
                  alert: "No user found with that email address."
      return
    end

    @membership = @organization.memberships.build(
      user: invited_user,
      role: membership_params[:role] || :member
    )
    authorize @membership

    if @membership.save
      redirect_to organization_memberships_path(@organization),
                  notice: "#{invited_user.name} has been added to the organization."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @membership
    @membership.destroy!
    redirect_to organization_memberships_path(@organization),
                notice: "Member was successfully removed."
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:organization_slug])
  end

  def set_membership
    @membership = @organization.memberships.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:email, :role)
  end
end
