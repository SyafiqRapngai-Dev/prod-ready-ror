class ProjectMemberPolicy < ApplicationPolicy
  def index?
    project_manager? || org_admin_or_owner?
  end

  def new?
    create?
  end

  def create?
    project_manager? || org_admin_or_owner?
  end

  def update?
    project_manager? || org_admin_or_owner?
  end

  def destroy?
    project_manager? || org_admin_or_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(project: { organization: :memberships })
           .where(memberships: { user_id: user.id })
    end
  end

  private

  def project
    @project ||= record.project
  end

  def organization
    @organization ||= project.organization
  end

  def org_membership
    @org_membership ||= organization.memberships.find_by(user_id: user.id)
  end

  def project_membership
    @project_membership ||= project.project_members.find_by(user_id: user.id)
  end

  def org_admin_or_owner?
    org_membership&.admin? || org_membership&.owner?
  end

  def project_manager?
    project_membership&.manager?
  end
end
