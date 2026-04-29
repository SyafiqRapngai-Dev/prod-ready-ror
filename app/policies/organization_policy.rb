class OrganizationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    member?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owner? || admin?
  end

  def edit?
    update?
  end

  def destroy?
    owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:memberships).where(memberships: { user_id: user.id })
    end
  end

  private

  def membership
    @membership ||= record.memberships.find_by(user_id: user.id)
  end

  def member?
    membership.present?
  end

  def admin?
    membership&.admin?
  end

  def owner?
    membership&.owner?
  end
end
