class ColumnPolicy < ApplicationPolicy
  def create?
    project_manager? || org_admin_or_owner?
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
    project_manager? || org_admin_or_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(board: { project: :organization })
           .joins("INNER JOIN memberships ON memberships.organization_id = organizations.id AND memberships.user_id = #{user.id.to_i}")
    end
  end

  private

  def project
    @project ||= record.board.project
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
end
