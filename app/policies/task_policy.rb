class TaskPolicy < ApplicationPolicy
  def index?
    project_member? || org_admin_or_owner?
  end

  def show?
    project_member? || org_admin_or_owner?
  end

  def create?
    project_member? || org_admin_or_owner?
  end

  def new?
    create?
  end

  def update?
    creator? || assignee? || project_manager? || org_admin_or_owner?
  end

  def edit?
    update?
  end

  def destroy?
    creator? || project_manager? || org_admin_or_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(project: :organization)
           .joins("INNER JOIN memberships ON memberships.organization_id = organizations.id AND memberships.user_id = #{user.id}")
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

  def project_member?
    project_membership.present?
  end

  def project_manager?
    project_membership&.manager?
  end

  def creator?
    record.created_by_id == user.id
  end

  def assignee?
    record.task_assignments.exists?(user_id: user.id)
  end
end
