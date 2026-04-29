class CommentPolicy < ApplicationPolicy
  def create?
    project_member? || org_admin_or_owner?
  end

  def new?
    create?
  end

  def update?
    author? || project_manager? || org_admin_or_owner?
  end

  def edit?
    update?
  end

  def destroy?
    author? || project_manager? || org_admin_or_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(task: { project: :organization })
           .joins("INNER JOIN memberships ON memberships.organization_id = organizations.id AND memberships.user_id = #{user.id}")
    end
  end

  private

  def task
    @task ||= record.task
  end

  def project
    @project ||= task.project
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

  def author?
    record.user_id == user.id
  end
end
