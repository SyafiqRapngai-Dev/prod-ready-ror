class ProjectPolicy < ApplicationPolicy
  def index?
    org_member?
  end

  def show?
    project_member? || org_admin_or_owner?
  end

  def create?
    org_admin_or_owner?
  end

  def new?
    create?
  end

  def update?
    project_manager? || org_admin_or_owner?
  end

  def edit?
    update?
  end

  def destroy?
    org_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:organization)
           .joins("INNER JOIN memberships ON memberships.organization_id = organizations.id AND memberships.user_id = #{user.id}")
           .or(
             scope.joins(:project_members)
                  .where(project_members: { user_id: user.id })
           )
           .distinct
    end
  end

  private

  def organization
    @organization ||= record.organization
  end

  def org_membership
    @org_membership ||= organization.memberships.find_by(user_id: user.id)
  end

  def project_membership
    @project_membership ||= record.project_members.find_by(user_id: user.id)
  end

  def org_member?
    org_membership.present?
  end

  def org_admin_or_owner?
    org_membership&.admin? || org_membership&.owner?
  end

  def org_owner?
    org_membership&.owner?
  end

  def project_member?
    project_membership.present?
  end

  def project_manager?
    project_membership&.manager?
  end
end
