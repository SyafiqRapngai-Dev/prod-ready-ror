class MembershipPolicy < ApplicationPolicy
  def index?
    org_member?
  end

  def new?
    org_admin_or_owner?
  end

  def create?
    org_admin_or_owner?
  end

  def destroy?
    org_owner? || record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:organization)
           .joins("INNER JOIN memberships AS user_memberships ON user_memberships.organization_id = organizations.id AND user_memberships.user_id = #{user.id}")
    end
  end

  private

  def organization
    @organization ||= record.organization
  end

  def org_membership
    @org_membership ||= organization.memberships.find_by(user_id: user.id)
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
end
